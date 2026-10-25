//
//  WidgetForgeSyncTask.swift
//  WidgetForgeKit
//
//  Public BGTaskScheduler orchestrator for WidgetForge + publisher apps.
//  Modeled on Wellness's BackgroundSyncManager.swift.
//
//  Structure: the BGTask-facing entry points are gated on iOS-only imports
//  because `BackgroundTasks.framework` is marked NS_UNAVAILABLE on macOS SPM
//  builds. The pure retry loop (`runWithRetry`) stays unguarded so it is
//  unit-testable on the host machine.
//

import Foundation
import os

public enum WidgetForgeSyncLog {
    public static let subsystem = "com.example.widgetforge.sync"
    public static let scheduler = Logger(subsystem: subsystem, category: "scheduler")
    public static let handler   = Logger(subsystem: subsystem, category: "handler")
    public static let publish   = Logger(subsystem: subsystem, category: "publish")
}

/// Marker for error types the retry loop must NOT retry (e.g. permanent OAuth
/// failure). Concrete SDK errors that fit this shape should adopt it.
public protocol WidgetForgeSyncNonRetryable: Error {}

public enum WidgetForgeSyncError: Error, WidgetForgeSyncNonRetryable, Sendable {
    case oauthUnrecoverable
    case backgroundNotEligible
    case underlying(String)
}

public struct WidgetForgeSyncTask: Sendable {

    public struct RetryPolicy: Sendable {
        public let maxAttempts: Int
        public let initialBackoff: TimeInterval
        public let backoffMultiplier: Double
        public init(maxAttempts: Int = 2, initialBackoff: TimeInterval = 2, backoffMultiplier: Double = 2) {
            self.maxAttempts = max(1, maxAttempts)
            self.initialBackoff = max(0, initialBackoff)
            self.backoffMultiplier = max(1, backoffMultiplier)
        }
        public static let `default` = RetryPolicy()
    }

    /// Pure retry loop — unit-testable without BGTaskScheduler.
    /// Returns true on any successful fetch+publish, false otherwise.
    public static func runWithRetry<T: Sendable>(
        identifier: String,
        retryPolicy: RetryPolicy,
        fetch: @escaping @Sendable () async throws -> T,
        publish: @escaping @Sendable (T) async throws -> Void,
        sleep: @escaping @Sendable (UInt64) async throws -> Void = { try await Task.sleep(nanoseconds: $0) }
    ) async -> Bool {
        var attempt = 0
        var backoff = retryPolicy.initialBackoff
        while attempt < retryPolicy.maxAttempts {
            attempt += 1
            if Task.isCancelled { return false }
            do {
                let payload = try await fetch()
                if Task.isCancelled { return false }
                try await publish(payload)
                return true
            } catch is CancellationError {
                return false
            } catch let err where err is WidgetForgeSyncNonRetryable {
                WidgetForgeSyncLog.handler.error("non-retryable id=\(identifier, privacy: .public) err=\(String(describing: err), privacy: .public)")
                return false
            } catch {
                let willRetry = attempt < retryPolicy.maxAttempts
                WidgetForgeSyncLog.handler.error("retryable id=\(identifier, privacy: .public) attempt=\(attempt) willRetry=\(willRetry)")
                if !willRetry { return false }
                let ns = UInt64(max(0, backoff) * 1_000_000_000)
                do { try await sleep(ns) } catch { return false }
                backoff *= retryPolicy.backoffMultiplier
            }
        }
        return false
    }

    // MARK: - iOS-only BGTaskScheduler surface

    #if canImport(BackgroundTasks) && !os(macOS)

    // Note: BackgroundTasks import is scoped to the extension so macOS SPM
    // builds (which reject BGTaskScheduler as NS_UNAVAILABLE) still compile
    // the rest of this type and its pure retry loop.

    @discardableResult
    public static func register<T: Sendable>(
        identifier: String,
        earliestInterval: TimeInterval = 60 * 60,
        retryPolicy: RetryPolicy = .default,
        fetch: @escaping @Sendable () async throws -> T,
        publish: @escaping @Sendable (T) async throws -> Void
    ) -> Bool {
        let registered = _BGRegistrar.register(identifier: identifier) { task in
            handle(task, identifier: identifier, earliestInterval: earliestInterval,
                   retryPolicy: retryPolicy, fetch: fetch, publish: publish)
        }
        if registered {
            WidgetForgeSyncLog.scheduler.info("registered id=\(identifier, privacy: .public)")
        } else {
            WidgetForgeSyncLog.scheduler.error("register FAILED id=\(identifier, privacy: .public) — check Info.plist BGTaskSchedulerPermittedIdentifiers")
        }
        return registered
    }

    public static func schedule(identifier: String, earliestInterval: TimeInterval = 60 * 60, reason: String = "schedule") {
        _BGRegistrar.submit(identifier: identifier, earliestInterval: earliestInterval, reason: reason)
    }

    private static func handle<T: Sendable>(_ task: _AnyBGRefreshTask, identifier: String,
                                            earliestInterval: TimeInterval, retryPolicy: RetryPolicy,
                                            fetch: @escaping @Sendable () async throws -> T,
                                            publish: @escaping @Sendable (T) async throws -> Void) {
        WidgetForgeSyncLog.handler.info("start id=\(identifier, privacy: .public)")
        // Always reschedule immediately so a crash before completion still
        // leaves the next window queued.
        schedule(identifier: identifier, earliestInterval: earliestInterval, reason: "handlerStarted")

        let completion = CompletionBox()
        let work = Task { await runWithRetry(identifier: identifier, retryPolicy: retryPolicy, fetch: fetch, publish: publish) }

        task.setExpiration {
            WidgetForgeSyncLog.handler.error("expired id=\(identifier, privacy: .public)")
            work.cancel()
            if completion.finish() { task.complete(false) }
        }

        Task {
            let success = await work.value
            if completion.finish() {
                WidgetForgeSyncLog.handler.info("done id=\(identifier, privacy: .public) success=\(success)")
                task.complete(success)
            }
        }
    }

    #endif

    private final class CompletionBox: @unchecked Sendable {
        private let lock = NSLock()
        private var done = false
        func finish() -> Bool {
            lock.lock(); defer { lock.unlock() }
            if done { return false }
            done = true; return true
        }
    }
}

// MARK: - BGTask indirection (iOS-only)
//
// Kept in a separate file scope so macOS SPM builds never import
// BackgroundTasks. The indirection matters because BGTaskScheduler /
// BGAppRefreshTask are annotated NS_UNAVAILABLE on macOS.

#if canImport(BackgroundTasks) && !os(macOS)
import BackgroundTasks

/// Existential-ish wrapper so `handle(_:)` above doesn't leak BGAppRefreshTask
/// into the macOS build path. Marked Sendable because both closures only
/// forward to BGAppRefreshTask methods that the framework itself allows to be
/// called from any actor context.
struct _AnyBGRefreshTask: @unchecked Sendable {
    let setExpiration: (@escaping @Sendable () -> Void) -> Void
    let complete: (Bool) -> Void
}

enum _BGRegistrar {
    static func register(identifier: String,
                         work: @escaping (_AnyBGRefreshTask) -> Void) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            guard let refresh = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false); return
            }
            let wrapped = _AnyBGRefreshTask(
                setExpiration: { handler in refresh.expirationHandler = handler },
                complete: { refresh.setTaskCompleted(success: $0) }
            )
            work(wrapped)
        }
    }

    static func submit(identifier: String, earliestInterval: TimeInterval, reason: String) {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: max(60, earliestInterval))
        do {
            try BGTaskScheduler.shared.submit(request)
            WidgetForgeSyncLog.scheduler.info("scheduled id=\(identifier, privacy: .public) reason=\(reason, privacy: .public)")
        } catch let error as BGTaskScheduler.Error {
            WidgetForgeSyncLog.scheduler.error("schedule failed id=\(identifier, privacy: .public) reason=\(reason, privacy: .public) code=\(error.code.rawValue)")
        } catch {
            WidgetForgeSyncLog.scheduler.error("schedule failed id=\(identifier, privacy: .public) reason=\(reason, privacy: .public) err=\(error.localizedDescription, privacy: .public)")
        }
    }
}
#endif
