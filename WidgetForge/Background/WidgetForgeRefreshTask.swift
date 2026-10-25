//
//  WidgetForgeRefreshTask.swift
//  WidgetForge
//
//  WidgetForge's own BGAppRefreshTask. iOS wakes us periodically; we
//  (1) re-read every AppCapabilityManifest so the UI reflects peer updates,
//  (2) prune manifests for uninstalled publisher apps,
//  (3) reload all timelines,
//  (4) reschedule. WidgetForge itself does no network work — all fetching
//  lives in the publisher apps' BGTasks.
//

import Foundation
import BackgroundTasks
import WidgetForgeKit
import WidgetKit
import UIKit
import os

enum WidgetForgeRefreshTask {
    static let taskIdentifier = "com.example.widgetforge.refresh"
    static let earliestInterval: TimeInterval = 60 * 60
    private static let logger = Logger(subsystem: "com.example.widgetforge.sync", category: "widgetforge.self")

    static func register() {
        let ok = BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let refresh = task as? BGAppRefreshTask else { task.setTaskCompleted(success: false); return }
            handle(refresh)
        }
        logger.info("register registered=\(ok) id=\(taskIdentifier, privacy: .public)")
    }

    static func schedule(reason: String) {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: earliestInterval)
        do { try BGTaskScheduler.shared.submit(request); logger.info("scheduled reason=\(reason, privacy: .public)") }
        catch { logger.error("schedule failed err=\(error.localizedDescription, privacy: .public)") }
    }

    private static func handle(_ task: BGAppRefreshTask) {
        logger.info("handler start")
        schedule(reason: "handlerStarted")
        let box = CompletionBox()
        // BGAppRefreshTask is not Sendable but the framework allows the
        // completion + expiration calls from any actor. Wrap in an unchecked
        // Sendable adapter so Task.detached can call through it.
        let taskRef = TaskRef(task: task)
        task.expirationHandler = {
            logger.error("expired")
            if box.finish() { taskRef.task.setTaskCompleted(success: false) }
        }
        Task.detached {
            let ok = await runOnce()
            if box.finish() { taskRef.task.setTaskCompleted(success: ok) }
        }
    }

    private final class CompletionBox: @unchecked Sendable {
        private let lock = NSLock(); private var done = false
        func finish() -> Bool {
            lock.lock(); defer { lock.unlock() }
            if done { return false }
            done = true; return true
        }
    }

    private final class TaskRef: @unchecked Sendable {
        let task: BGAppRefreshTask
        init(task: BGAppRefreshTask) { self.task = task }
    }

    static func runOnce() async -> Bool {
        let store = ManifestStore()
        let manifests = store.readAll()
        logger.info("read \(manifests.count) manifest(s)")

        let probe = await MainActor.run { UIKitURLSchemeProbe() }
        let availability = AppAvailability(registry: .default, manifests: store, probe: probe)
        let results = await MainActor.run { availability.results() }
        let removed = AppAvailability.pruneUninstalled(results: results, store: store)
        logger.info("pruned \(removed) uninstalled")

        await MainActor.run { WidgetCenter.shared.reloadAllTimelines() }
        return true
    }
}
