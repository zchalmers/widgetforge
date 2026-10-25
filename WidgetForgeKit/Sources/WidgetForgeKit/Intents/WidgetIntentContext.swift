import Foundation

/// Sendable snapshot of a slice used by intent dialogs and snippets. Mirrors
/// only the raw data intents need so we never re-encode `SliceValue` through
/// non-Sendable pathways at the AppEntity boundary.
public struct WidgetIntentSliceSnapshot: Sendable, Equatable {
    public let bundleId: String
    public let appDisplayName: String
    public let accentHex: String
    public let scheme: String
    public let sliceId: String
    public let sliceDisplayName: String
    public let kind: SliceKind
    public let value: SliceValue
    public let deepLink: URL?
    public let refreshedAt: Date

    public init(bundleId: String,
                appDisplayName: String,
                accentHex: String,
                scheme: String,
                sliceId: String,
                sliceDisplayName: String,
                kind: SliceKind,
                value: SliceValue,
                deepLink: URL?,
                refreshedAt: Date) {
        self.bundleId = bundleId
        self.appDisplayName = appDisplayName
        self.accentHex = accentHex
        self.scheme = scheme
        self.sliceId = sliceId
        self.sliceDisplayName = sliceDisplayName
        self.kind = kind
        self.value = value
        self.deepLink = deepLink
        self.refreshedAt = refreshedAt
    }
}

/// Pure functions that resolve intent-facing questions against AppRegistry +
/// ManifestStore. Every intent perform() body should be a one-liner into here.
public enum WidgetIntentContext {

    /// Union of currently-published manifests and registry entries that appear
    /// in KnownSliceCatalog. Used to power `PublishingAppEntity.suggestedEntities()`.
    public struct AppSuggestion: Sendable, Equatable {
        public let entry: AppRegistry.Entry
        public let hasManifest: Bool
        public init(entry: AppRegistry.Entry, hasManifest: Bool) {
            self.entry = entry
            self.hasManifest = hasManifest
        }
    }

    public struct SliceSuggestion: Sendable, Equatable {
        public let entry: AppRegistry.Entry
        public let sliceId: String
        public let sliceDisplayName: String
        public let kind: SliceKind
        public let hasManifest: Bool
        public init(entry: AppRegistry.Entry, sliceId: String, sliceDisplayName: String, kind: SliceKind, hasManifest: Bool) {
            self.entry = entry
            self.sliceId = sliceId
            self.sliceDisplayName = sliceDisplayName
            self.kind = kind
            self.hasManifest = hasManifest
        }
    }

    // MARK: - Suggestions

    public static func appSuggestions(registry: AppRegistry = .default,
                                      store: ManifestStore = ManifestStore()) -> [AppSuggestion] {
        let manifests = store.readAll()
        let publishing = Set(manifests.map { $0.bundleId })
        return registry.entries.compactMap { entry in
            let hasManifest = publishing.contains(entry.bundleId)
            let hasCatalog = !KnownSliceCatalog.slices(for: entry.bundleId).isEmpty
            guard hasManifest || hasCatalog else { return nil }
            return AppSuggestion(entry: entry, hasManifest: hasManifest)
        }
    }

    public static func sliceSuggestions(registry: AppRegistry = .default,
                                        store: ManifestStore = ManifestStore()) -> [SliceSuggestion] {
        let manifests = store.readAll()
        let byBundle = Dictionary(uniqueKeysWithValues: manifests.map { ($0.bundleId, $0) })
        var out: [SliceSuggestion] = []
        for entry in registry.entries {
            if let m = byBundle[entry.bundleId] {
                for s in m.slices {
                    out.append(SliceSuggestion(entry: entry,
                                               sliceId: s.id,
                                               sliceDisplayName: s.displayName,
                                               kind: s.kind,
                                               hasManifest: true))
                }
            }
            for k in KnownSliceCatalog.slices(for: entry.bundleId) {
                // Skip duplicates already covered by the live manifest.
                if byBundle[entry.bundleId]?.slices.contains(where: { $0.id == k.sliceId }) == true {
                    continue
                }
                out.append(SliceSuggestion(entry: entry,
                                           sliceId: k.sliceId,
                                           sliceDisplayName: k.displayName,
                                           kind: k.kind,
                                           hasManifest: false))
            }
        }
        return out
    }

    // MARK: - Resolution

    public static func entry(for bundleId: String,
                             registry: AppRegistry = .default) -> AppRegistry.Entry? {
        registry.entry(for: bundleId)
    }

    public static func manifest(for bundleId: String,
                                store: ManifestStore = ManifestStore()) -> AppCapabilityManifest? {
        store.read(bundleId: bundleId)
    }

    public static func firstSlice(of kind: SliceKind,
                                  in manifest: AppCapabilityManifest) -> DataSlice? {
        manifest.slices.first { $0.kind == kind }
    }

    /// Look up `(entry, manifest, slice)` for the first slice of the requested
    /// kind, or `nil` if any layer is missing. This is the workhorse behind
    /// every kind-specific intent.
    public static func snapshot(for bundleId: String,
                                kind: SliceKind,
                                registry: AppRegistry = .default,
                                store: ManifestStore = ManifestStore()) -> WidgetIntentSliceSnapshot? {
        guard let entry = registry.entry(for: bundleId),
              let manifest = store.read(bundleId: bundleId),
              let slice = firstSlice(of: kind, in: manifest) else { return nil }
        return WidgetIntentSliceSnapshot(bundleId: entry.bundleId,
                                      appDisplayName: entry.displayName,
                                      accentHex: entry.accentHex,
                                      scheme: entry.scheme,
                                      sliceId: slice.id,
                                      sliceDisplayName: slice.displayName,
                                      kind: slice.kind,
                                      value: slice.value,
                                      deepLink: slice.deepLink,
                                      refreshedAt: slice.refreshedAt)
    }

    /// Resolves a specific slice by (bundleId, sliceId).
    public static func snapshot(for bundleId: String,
                                sliceId: String,
                                registry: AppRegistry = .default,
                                store: ManifestStore = ManifestStore()) -> WidgetIntentSliceSnapshot? {
        guard let entry = registry.entry(for: bundleId),
              let manifest = store.read(bundleId: bundleId),
              let slice = manifest.slices.first(where: { $0.id == sliceId }) else { return nil }
        return WidgetIntentSliceSnapshot(bundleId: entry.bundleId,
                                      appDisplayName: entry.displayName,
                                      accentHex: entry.accentHex,
                                      scheme: entry.scheme,
                                      sliceId: slice.id,
                                      sliceDisplayName: slice.displayName,
                                      kind: slice.kind,
                                      value: slice.value,
                                      deepLink: slice.deepLink,
                                      refreshedAt: slice.refreshedAt)
    }

    // MARK: - Deep links

    public static func openURL(for entry: AppRegistry.Entry) -> URL {
        URL(string: "\(entry.scheme)://")!
    }

    public static func openURL(for snapshot: WidgetIntentSliceSnapshot) -> URL {
        snapshot.deepLink ?? URL(string: "\(snapshot.scheme)://")!
    }

    // MARK: - Speech helpers

    /// Human-readable dialog string for a snapshot. Kept here (not in the
    /// intent file) so it is unit-testable without importing AppIntents.
    public static func spokenDialog(for snapshot: WidgetIntentSliceSnapshot,
                                    listLimit: Int = 3) -> String {
        switch snapshot.value {
        case .count(let n):
            return "You have \(n) pending in \(snapshot.appDisplayName)."
        case .list(let items):
            let top = items.prefix(listLimit).map(\.title).joined(separator: ", ")
            if items.isEmpty {
                return "\(snapshot.appDisplayName) has nothing to show."
            }
            return "Top \(min(listLimit, items.count)) in \(snapshot.appDisplayName): \(top)."
        case .metric(let value, let unit, let trend):
            let unitText = unit.map { " \($0)" } ?? ""
            let trendText: String
            switch trend {
            case .some(.up): trendText = ", trending up"
            case .some(.down): trendText = ", trending down"
            case .some(.flat): trendText = ", flat"
            case .none: trendText = ""
            }
            let formatted = String(format: "%g", value)
            return "\(snapshot.sliceDisplayName) in \(snapshot.appDisplayName): \(formatted)\(unitText)\(trendText)."
        case .status(let status, let text):
            let label: String
            switch status {
            case .ok: label = "OK"
            case .warning: label = "warning"
            case .critical: label = "critical"
            }
            return "\(snapshot.appDisplayName) status is \(label): \(text)."
        case .progress(let fraction, let label):
            let pct = Int((fraction.clamped01() * 100).rounded())
            return "\(label) in \(snapshot.appDisplayName): \(pct) percent."
        }
    }

    // MARK: - Summarization inputs

    /// Compact plain-text digest of every published manifest — used as prompt
    /// input for SummarizeWidgetIntent (or as the fallback dialog when
    /// Foundation Models is unavailable).
    public static func manifestsDigest(store: ManifestStore = ManifestStore(),
                                       registry: AppRegistry = .default) -> String {
        let manifests = store.readAll()
        guard !manifests.isEmpty else { return "No Widget apps are publishing data yet." }
        let byBundle = Dictionary(uniqueKeysWithValues: registry.entries.map { ($0.bundleId, $0) })
        var lines: [String] = []
        for m in manifests.sorted(by: { $0.displayName < $1.displayName }) {
            let name = byBundle[m.bundleId]?.displayName ?? m.displayName
            var parts: [String] = []
            for s in m.slices {
                switch s.value {
                case .count(let n):
                    parts.append("\(s.displayName)=\(n)")
                case .list(let items):
                    parts.append("\(s.displayName)=\(items.count) items")
                case .metric(let v, let unit, _):
                    parts.append("\(s.displayName)=\(String(format: "%g", v))\(unit.map { " \($0)" } ?? "")")
                case .status(let st, _):
                    parts.append("\(s.displayName)=\(st.rawValue)")
                case .progress(let f, _):
                    parts.append("\(s.displayName)=\(Int((f.clamped01() * 100).rounded()))%")
                }
            }
            lines.append("\(name): \(parts.joined(separator: ", "))")
        }
        return lines.joined(separator: "\n")
    }

    /// Cheap template summary used when Foundation Models is unavailable.
    public static func fallbackSummary(store: ManifestStore = ManifestStore(),
                                       registry: AppRegistry = .default) -> String {
        let manifests = store.readAll()
        if manifests.isEmpty { return "No Widget apps are publishing data yet." }
        let byBundle = Dictionary(uniqueKeysWithValues: registry.entries.map { ($0.bundleId, $0) })
        let bits: [String] = manifests.compactMap { m in
            let name = byBundle[m.bundleId]?.displayName ?? m.displayName
            let counts = m.slices.compactMap { s -> String? in
                if case .count(let n) = s.value { return "\(n) in \(name)" }
                return nil
            }
            return counts.first ?? "\(name) is up to date"
        }
        return "Across your Widget apps: " + bits.joined(separator: "; ") + "."
    }
}

private extension Double {
    func clamped01() -> Double { min(1, max(0, self)) }
}
