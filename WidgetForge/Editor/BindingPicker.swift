import SwiftUI
import WidgetForgeKit

// `KnownSlice` and `KnownSliceCatalog` now ship from WidgetForgeKit
// (see WidgetForgeKit/Registry/KnownSliceCatalog.swift) so the App Intents
// layer and the widget extension can share the same table. Their public
// shape is identical to what was previously declared here.

/// Two-tier data-binding picker. Tier 1 lists currently-publishing apps (from
/// `ManifestStore().readAll()`) with only slices whose `kind` matches
/// `requiredKind` — this closes the runtime gap where `SlicePool.slice(for:)`
/// doesn't verify kind. Tier 2 lists known catalog entries for
/// registered-but-not-yet-publishing apps so users can pre-bind before an app
/// has ever run.
struct BindingPicker: View {
    let requiredKind: SliceKind
    @Binding var selection: DataBinding?
    @Environment(\.dismiss) private var dismiss

    @State private var manifests: [AppCapabilityManifest] = []
    @State private var registry: AppRegistry = .default

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if publishingCandidates.isEmpty {
                        ContentUnavailableView(
                            "No matching data",
                            systemImage: "square.stack.3d.up.slash",
                            description: Text("No app is publishing a \(kindLabel) slice yet. Open a Widget app to activate it, or pick a known slice below.")
                        )
                    } else {
                        ForEach(publishingCandidates, id: \.self) { candidate in
                            Button {
                                selection = DataBinding(bundleId: candidate.bundleId, sliceId: candidate.sliceId)
                                dismiss()
                            } label: {
                                bindingRow(bundleId: candidate.bundleId,
                                           displayName: candidate.displayName,
                                           sliceLabel: candidate.sliceDisplayName,
                                           sliceKind: candidate.sliceKind,
                                           isPublishing: true)
                            }
                        }
                    }
                } header: {
                    Text("Publishing now")
                } footer: {
                    Text("These slices are already available and will render immediately.")
                }

                Section {
                    ForEach(knownCandidates, id: \.self) { candidate in
                        Button {
                            selection = DataBinding(bundleId: candidate.bundleId, sliceId: candidate.slice.sliceId)
                            dismiss()
                        } label: {
                            bindingRow(bundleId: candidate.bundleId,
                                       displayName: candidate.displayName,
                                       sliceLabel: candidate.slice.displayName,
                                       sliceKind: candidate.slice.kind,
                                       isPublishing: false)
                        }
                    }
                } header: {
                    Text("Known apps not yet publishing")
                } footer: {
                    Text("Widget shows an empty state until the app publishes.")
                }
            }
            .navigationTitle("Bind data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                manifests = ManifestStore().readAll()
            }
        }
    }

    // MARK: - Candidate assembly

    private struct PublishingCandidate: Hashable {
        let bundleId: String
        let displayName: String
        let sliceId: String
        let sliceDisplayName: String
        let sliceKind: SliceKind
    }

    private struct KnownCandidate: Hashable {
        let bundleId: String
        let displayName: String
        let slice: KnownSlice
    }

    private var publishingCandidates: [PublishingCandidate] {
        var out: [PublishingCandidate] = []
        for m in manifests {
            for s in m.slices where s.kind == requiredKind {
                out.append(PublishingCandidate(bundleId: m.bundleId,
                                               displayName: m.displayName,
                                               sliceId: s.id,
                                               sliceDisplayName: s.displayName,
                                               sliceKind: s.kind))
            }
        }
        return out.sorted { $0.displayName < $1.displayName }
    }

    private var knownCandidates: [KnownCandidate] {
        let publishedBundleIds = Set(manifests.map(\.bundleId))
        var out: [KnownCandidate] = []
        // Group by displayName so Inbox (prod) and Inbox (internal) collapse.
        var seenDisplayNames: Set<String> = []
        for entry in registry.entries {
            guard !publishedBundleIds.contains(entry.bundleId) else { continue }
            let slices = KnownSliceCatalog.slices(for: entry.bundleId).filter { $0.kind == requiredKind }
            for s in slices {
                let key = "\(entry.displayName):\(s.sliceId)"
                guard !seenDisplayNames.contains(key) else { continue }
                seenDisplayNames.insert(key)
                out.append(KnownCandidate(bundleId: entry.bundleId,
                                          displayName: entry.displayName,
                                          slice: s))
            }
        }
        return out.sorted { $0.displayName < $1.displayName }
    }

    private var kindLabel: String {
        switch requiredKind {
        case .count: return "count"
        case .list: return "list"
        case .metric: return "metric"
        case .status: return "status"
        case .progress: return "progress"
        }
    }

    @ViewBuilder
    private func bindingRow(bundleId: String,
                            displayName: String,
                            sliceLabel: String,
                            sliceKind: SliceKind,
                            isPublishing: Bool) -> some View {
        let accent = DesignSystem.accent(for: bundleId)
        HStack(spacing: 12) {
            Image(systemName: accent.symbol)
                .font(.title2)
                .foregroundStyle(accent.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(sliceLabel)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(kindBadge(sliceKind))
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(accent.tint.opacity(isPublishing ? 0.20 : 0.08)))
                .foregroundStyle(isPublishing ? .primary : .secondary)
        }
    }

    private func kindBadge(_ kind: SliceKind) -> String {
        switch kind {
        case .count: return "COUNT"
        case .list: return "LIST"
        case .metric: return "METRIC"
        case .status: return "STATUS"
        case .progress: return "PROGRESS"
        }
    }
}
