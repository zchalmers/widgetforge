import SwiftUI
import WidgetForgeKit
import WidgetKit
import UIKit

/// Debug-only inspector for the shared App Group container. Shows every file on
/// disk, every parsed manifest and slice value, and all stored layouts, so you
/// can verify that publisher background tasks, the shared group, and updates are
/// actually working. Read-only except for manual refresh / timeline reload.
struct DebugDataView: View {
    @State private var snapshot = DebugSnapshot.empty

    var body: some View {
        NavigationStack {
            List {
                containerSection
                manifestsSection
                layoutsSection
                rawFilesSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Debug")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        WidgetCenter.shared.reloadAllTimelines()
                        reload()
                    } label: { Label("Reload", systemImage: "arrow.clockwise") }
                }
            }
            .task { reload() }
            .refreshable { reload() }
        }
    }

    // MARK: - Sections

    private var containerSection: some View {
        Section("Shared container") {
            kv("App Group", snapshot.appGroup)
            kv("Reachable", snapshot.containerURL == nil ? "NO — container unavailable" : "yes")
            if let url = snapshot.containerURL {
                kv("Path", url.path)
            }
            kv("Manifest files", "\(snapshot.files.count)")
            kv("Parsed manifests", "\(snapshot.manifests.count)")
            kv("Stored layouts", "\(snapshot.layouts.count)")
            kv("Snapshot taken", snapshot.takenAt.formatted(date: .omitted, time: .standard))
        }
    }

    private var manifestsSection: some View {
        Section("Manifests (\(snapshot.manifests.count))") {
            if snapshot.manifests.isEmpty {
                Text("No manifests in the shared container. No publisher has written data yet.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            ForEach(snapshot.manifests, id: \.bundleId) { m in
                DisclosureGroup {
                    kv("bundleId", m.bundleId)
                    kv("displayName", m.displayName)
                    kv("schemaVersion", "\(m.schemaVersion)")
                    kv("accentHex", m.accentHex)
                    kv("iconAssetName", m.iconAssetName ?? "nil")
                    kv("deepLinkScheme", m.deepLinkScheme)
                    kv("refreshedAt", "\(m.refreshedAt.formatted(date: .abbreviated, time: .standard))  (\(m.refreshedAt.relativeAgeString))")
                    kv("slices", "\(m.slices.count)")
                    ForEach(m.slices, id: \.id) { s in
                        VStack(alignment: .leading, spacing: 3) {
                            Text("• \(s.id)")
                                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                            kvInline("displayName", s.displayName)
                            kvInline("kind", s.kind.rawValue)
                            kvInline("value", s.value.debugString)
                            kvInline("deepLink", s.deepLink?.absoluteString ?? "nil")
                            kvInline("refreshedAt", "\(s.refreshedAt.relativeAgeString)")
                        }
                        .padding(.vertical, 2)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(m.displayName).font(.headline)
                        Text("\(m.bundleId) · \(m.slices.count) slices · \(m.refreshedAt.relativeAgeString)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var layoutsSection: some View {
        Section("Stored layouts (\(snapshot.layouts.count))") {
            if snapshot.layouts.isEmpty {
                Text("No layouts stored.").font(.footnote).foregroundStyle(.secondary)
            }
            ForEach(snapshot.layouts, id: \.id) { l in
                DisclosureGroup {
                    kv("id", l.id.uuidString)
                    kv("family", l.family.rawValue)
                    kv("updatedAt", l.updatedAt.timeIntervalSince1970 == 0 ? "epoch (untouched seed)" : l.updatedAt.formatted(date: .abbreviated, time: .standard))
                    kv("cells", "\(l.cells.count)")
                    ForEach(l.cells, id: \.id) { c in
                        Text("• [\(c.origin.col),\(c.origin.row) \(c.span.cols)x\(c.span.rows)] \(c.debugComponentString)")
                            .font(.system(.caption, design: .monospaced))
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l.name).font(.headline)
                        Text("\(l.family.rawValue) · \(l.cells.count) cells").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var rawFilesSection: some View {
        Section("Raw files on disk (\(snapshot.files.count))") {
            ForEach(snapshot.files, id: \.name) { f in
                DisclosureGroup {
                    kv("size", "\(f.byteCount) bytes")
                    kv("modified", f.modifiedAt?.formatted(date: .abbreviated, time: .standard) ?? "?")
                    Text(f.contents)
                        .font(.system(.caption2, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(.vertical, 4)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(f.name).font(.system(.subheadline, design: .monospaced))
                        Text("\(f.byteCount) bytes").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Row helpers

    private func kv(_ k: String, _ v: String) -> some View {
        HStack(alignment: .top) {
            Text(k).font(.caption).foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(v).font(.system(.caption, design: .monospaced)).multilineTextAlignment(.trailing).textSelection(.enabled)
        }
    }

    private func kvInline(_ k: String, _ v: String) -> some View {
        (Text("\(k): ").font(.caption2).foregroundStyle(.secondary)
         + Text(v).font(.system(.caption2, design: .monospaced)))
            .textSelection(.enabled)
    }

    private func reload() {
        snapshot = DebugSnapshot.load()
    }
}

// MARK: - Snapshot model

private struct DebugSnapshot {
    var appGroup: String
    var containerURL: URL?
    var files: [FileDump]
    var manifests: [AppCapabilityManifest]
    var layouts: [WidgetLayout]
    var takenAt: Date

    struct FileDump {
        let name: String
        let byteCount: Int
        let modifiedAt: Date?
        let contents: String
    }

    static let empty = DebugSnapshot(appGroup: "", containerURL: nil, files: [], manifests: [], layouts: [], takenAt: Date(timeIntervalSince1970: 0))

    static func load() -> DebugSnapshot {
        let container = SharedContainer()
        let manifestStore = ManifestStore()
        let layoutStore = LayoutStore()

        var files: [FileDump] = []
        // Manifests directory
        if let dir = container.manifestsDirectoryURL(),
           let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) {
            for url in urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                files.append(dump(url: url, prefix: "manifests/"))
            }
        }
        // Layouts directory (incl. index.json)
        if let dir = container.layoutsDirectoryURL(),
           let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) {
            for url in urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                files.append(dump(url: url, prefix: "layouts/"))
            }
        }

        let manifests = manifestStore.readAll().sorted { $0.displayName < $1.displayName }
        let layouts: [WidgetLayout] = layoutStore.readIndex()
            .sorted { $0.updatedAt > $1.updatedAt }
            .compactMap { try? layoutStore.read(id: $0.id) }

        return DebugSnapshot(
            appGroup: container.appGroup,
            containerURL: container.containerURL,
            files: files,
            manifests: manifests,
            layouts: layouts,
            takenAt: Date()
        )
    }

    private static func dump(url: URL, prefix: String) -> FileDump {
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        let size = (attrs?[.size] as? Int) ?? 0
        let modified = attrs?[.modificationDate] as? Date
        let raw = (try? String(contentsOf: url, encoding: .utf8)) ?? "<unreadable>"
        // Pretty-print JSON if possible so it's actually readable.
        let pretty: String = {
            guard let data = raw.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: data),
                  let out = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
                  let s = String(data: out, encoding: .utf8) else { return raw }
            return s
        }()
        return FileDump(name: prefix + url.lastPathComponent, byteCount: size, modifiedAt: modified, contents: pretty)
    }
}

// MARK: - Debug string helpers

private extension Date {
    var relativeAgeString: String {
        if timeIntervalSince1970 == 0 { return "epoch" }
        let secs = Date().timeIntervalSince(self)
        if secs < 0 { return "in the future" }
        if secs < 60 { return "\(Int(secs))s ago" }
        if secs < 3600 { return "\(Int(secs / 60))m ago" }
        if secs < 86400 { return "\(Int(secs / 3600))h ago" }
        return "\(Int(secs / 86400))d ago"
    }
}

private extension SliceValue {
    var debugString: String {
        switch self {
        case .count(let n): return "count(\(n))"
        case .metric(let v, let unit, let trend):
            return "metric(\(v), unit: \(unit ?? "nil"), trend: \(trend?.rawValue ?? "nil"))"
        case .status(let s, let text): return "status(\(s.rawValue), \"\(text)\")"
        case .progress(let v, let label): return "progress(\(v), \"\(label)\")"
        case .list(let items):
            let rows = items.map { "    - \($0.title)\($0.subtitle.map { " / \($0)" } ?? "")" }.joined(separator: "\n")
            return "list(\(items.count) items)\n\(rows)"
        }
    }
}

private extension Cell {
    var debugComponentString: String {
        switch component {
        case .header(let c): return "header \"\(c.title)\""
        case .count(let c): return "count \(c.binding.bundleId)/\(c.binding.sliceId)"
        case .metric(let c): return "metric \(c.binding.bundleId)/\(c.binding.sliceId)"
        case .status(let c): return "status \(c.binding.bundleId)/\(c.binding.sliceId)"
        case .progress(let c): return "progress \(c.binding.bundleId)/\(c.binding.sliceId)"
        case .list(let c): return "list \(c.binding.bundleId)/\(c.binding.sliceId)"
        case .appTile(let c): return "appTile \(c.bundleId)"
        }
    }
}
