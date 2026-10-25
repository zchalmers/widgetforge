//
//  WidgetForgeSyncCoordinator.swift
//  WidgetForgeKit
//
//  Wrapper around ManifestStore.write + WidgetCenter.reloadAllTimelines.
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

public protocol WidgetForgeManifestPublishing: Sendable {
    func publish(_ manifest: AppCapabilityManifest) async throws
}

public struct WidgetForgeSyncCoordinator: WidgetForgeManifestPublishing {
    public let store: ManifestStore
    public let reload: @Sendable () -> Void

    public init(store: ManifestStore = ManifestStore(),
                reload: @escaping @Sendable () -> Void = Self.defaultReload) {
        self.store = store
        self.reload = reload
    }

    public func publish(_ manifest: AppCapabilityManifest) async throws {
        do {
            try store.write(manifest)
            WidgetForgeSyncLog.publish.info("wrote manifest bundle=\(manifest.bundleId, privacy: .public)")
        } catch {
            WidgetForgeSyncLog.publish.error("write failed bundle=\(manifest.bundleId, privacy: .public)")
            throw error
        }
        reload()
    }

    public static let defaultReload: @Sendable () -> Void = {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
