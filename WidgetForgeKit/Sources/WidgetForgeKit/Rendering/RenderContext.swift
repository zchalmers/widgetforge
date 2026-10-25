import Foundation

public struct SlicePool: Sendable, Equatable {
    public let byBundle: [String: AppCapabilityManifest]

    public init(_ manifests: [AppCapabilityManifest]) {
        var map: [String: AppCapabilityManifest] = [:]
        for m in manifests { map[m.bundleId] = m }
        self.byBundle = map
    }

    /// Exact-match lookup. Prefer the registry-aware overloads (or
    /// `RenderContext.manifest(for:)`) so an installed internal/dev variant
    /// resolves for a layout bound to the canonical (prod) id.
    public func manifest(for bundleId: String) -> AppCapabilityManifest? {
        byBundle[bundleId]
    }

    public func slice(for binding: DataBinding) -> DataSlice? {
        byBundle[binding.bundleId]?.slices.first(where: { $0.id == binding.sliceId })
    }

    /// Resolve a manifest for a bound bundle id, tolerating variant mismatch.
    /// A layout binds the canonical (prod) id, but an installed internal/dev
    /// build publishes under a variant id sharing the same app (same registry
    /// `displayName`). Exact match wins; otherwise any manifest belonging to a
    /// sibling variant of the same app is used.
    public func manifest(for bundleId: String, registry: AppRegistry) -> AppCapabilityManifest? {
        if let exact = byBundle[bundleId] { return exact }
        guard let displayName = registry.entry(for: bundleId)?.displayName else { return nil }
        let siblingIds = Set(registry.entries.filter { $0.displayName == displayName }.map(\.bundleId))
        return byBundle.values.first { siblingIds.contains($0.bundleId) }
    }

    /// Resolve a slice for a binding, tolerating bundle-id variant mismatch.
    public func slice(for binding: DataBinding, registry: AppRegistry) -> DataSlice? {
        manifest(for: binding.bundleId, registry: registry)?
            .slices.first(where: { $0.id == binding.sliceId })
    }
}

public struct RenderContext: Sendable {
    public let pool: SlicePool
    public let registry: AppRegistry
    public let now: Date

    public init(pool: SlicePool, registry: AppRegistry = .default, now: Date = Date()) {
        self.pool = pool
        self.registry = registry
        self.now = now
    }

    /// Resolve a manifest for a bound bundle id, tolerating variant mismatch.
    public func manifest(for bundleId: String) -> AppCapabilityManifest? {
        pool.manifest(for: bundleId, registry: registry)
    }

    /// Resolve a slice for a binding, tolerating bundle-id variant mismatch.
    public func slice(for binding: DataBinding) -> DataSlice? {
        pool.slice(for: binding, registry: registry)
    }
}
