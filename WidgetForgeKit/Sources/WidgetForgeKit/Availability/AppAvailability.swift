import Foundation

public protocol URLSchemeProbe: Sendable {
    func canOpen(scheme: String) -> Bool
}

public struct AppAvailability: Sendable {
    public enum Status: Equatable, Sendable {
        case ready
        case installedNotPublishing
        case notInstalled
        case stale(publishedAt: Date)

        public var isReady: Bool {
            if case .ready = self { return true }
            return false
        }
    }

    public struct Result: Sendable, Identifiable, Equatable {
        public let entry: AppRegistry.Entry
        public let status: Status
        public var id: String { entry.bundleId }
    }

    public static let staleAfter: TimeInterval = 60 * 60 * 24 * 7

    public let registry: AppRegistry
    public let manifests: ManifestStore
    public let probe: URLSchemeProbe
    public let now: @Sendable () -> Date

    public init(registry: AppRegistry,
                manifests: ManifestStore,
                probe: URLSchemeProbe,
                now: @Sendable @escaping () -> Date = { Date() }) {
        self.registry = registry
        self.manifests = manifests
        self.probe = probe
        self.now = now
    }

    public func status(for entry: AppRegistry.Entry) -> Status {
        guard entry.confirmed, !entry.scheme.isEmpty else { return .notInstalled }
        let installed = probe.canOpen(scheme: entry.scheme)
        let publishedAt = manifests.refreshedAt(bundleId: entry.bundleId)
        switch (installed, publishedAt) {
        case (false, _):
            return .notInstalled
        case (true, nil):
            return .installedNotPublishing
        case (true, .some(let at)):
            if now().timeIntervalSince(at) > Self.staleAfter {
                return .stale(publishedAt: at)
            }
            return .ready
        }
    }

    public func results() -> [Result] {
        registry.entries.map { Result(entry: $0, status: status(for: $0)) }
    }

    /// Deletes manifest files for any entry whose current status is `.notInstalled`.
    /// Best-effort: swallows per-entry removal errors so a transient container issue
    /// does not surface to the user. Returns the number of manifests actually removed
    /// so the caller can decide whether to trigger a WidgetKit reload.
    @discardableResult
    public static func pruneUninstalled(results: [Result], store: ManifestStore) -> Int {
        var removed = 0
        for r in results where r.status == .notInstalled {
            // Only remove if a manifest actually exists — avoids logging spurious errors
            // and keeps the operation a true no-op when there is nothing to clean up.
            guard store.read(bundleId: r.entry.bundleId) != nil else { continue }
            do {
                try store.remove(bundleId: r.entry.bundleId)
                removed += 1
            } catch {
                WFLog.store.error("prune failed for \(r.entry.bundleId, privacy: .public): \(String(describing: error), privacy: .public)")
            }
        }
        return removed
    }
}
