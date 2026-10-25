import SwiftUI
import WidgetForgeKit

/// Mutable staging state for a Component's kind-specific config. Kept as a
/// single struct so the add flow and `CellEditorView` can share the form UI
/// and just pull out a fresh `Component` at commit time. Fields carry defaults
/// so switching kinds does not clobber unrelated values.
struct ComponentDraft: Equatable {
    var kind: Component.Kind
    var binding: DataBinding?
    var accent: AccentChoice = .fromApp
    var headerTitle: String = "Header"
    var headerSubtitle: String = ""
    var countCaption: String = ""
    var metricCaption: String = ""
    var listMaxRows: Int = 3
    var progressStyle: ProgressStyle = .bar
    var appTileBundleId: String = "com.example.it.inbox"

    /// Every kind except `.header` and `.appTile` needs a binding before it
    /// can produce a valid Component. Called by the flow's Confirm button.
    var isReadyToCommit: Bool {
        switch kind {
        case .header:
            return !headerTitle.trimmingCharacters(in: .whitespaces).isEmpty
        case .appTile:
            return !appTileBundleId.isEmpty
        case .count, .list, .metric, .status, .progress:
            return binding != nil
        }
    }

    /// Build the final `Component` matching `kind`. Requires `isReadyToCommit`.
    func makeComponent() -> Component {
        switch kind {
        case .header:
            return .header(HeaderConfig(
                title: headerTitle,
                subtitle: headerSubtitle.isEmpty ? nil : headerSubtitle,
                accent: accent
            ))
        case .appTile:
            return .appTile(AppTileConfig(bundleId: appTileBundleId, accent: accent))
        case .count:
            return .count(CountConfig(
                binding: binding ?? DataBinding(bundleId: "", sliceId: ""),
                caption: countCaption.isEmpty ? nil : countCaption,
                accent: accent
            ))
        case .list:
            return .list(ListConfig(
                binding: binding ?? DataBinding(bundleId: "", sliceId: ""),
                maxRows: max(1, listMaxRows),
                accent: accent
            ))
        case .metric:
            return .metric(MetricConfig(
                binding: binding ?? DataBinding(bundleId: "", sliceId: ""),
                caption: metricCaption.isEmpty ? nil : metricCaption,
                accent: accent
            ))
        case .status:
            return .status(StatusConfig(
                binding: binding ?? DataBinding(bundleId: "", sliceId: ""),
                accent: accent
            ))
        case .progress:
            return .progress(ProgressConfig(
                binding: binding ?? DataBinding(bundleId: "", sliceId: ""),
                style: progressStyle,
                accent: accent
            ))
        }
    }

    /// Seed a draft from an existing Component so the edit form is pre-filled.
    static func from(_ component: Component) -> ComponentDraft {
        var d = ComponentDraft(kind: component.kind)
        switch component {
        case .header(let c):
            d.headerTitle = c.title
            d.headerSubtitle = c.subtitle ?? ""
            d.accent = c.accent
        case .appTile(let c):
            d.appTileBundleId = c.bundleId
            d.accent = c.accent
        case .count(let c):
            d.binding = c.binding
            d.countCaption = c.caption ?? ""
            d.accent = c.accent
        case .list(let c):
            d.binding = c.binding
            d.listMaxRows = c.maxRows
            d.accent = c.accent
        case .metric(let c):
            d.binding = c.binding
            d.metricCaption = c.caption ?? ""
            d.accent = c.accent
        case .status(let c):
            d.binding = c.binding
            d.accent = c.accent
        case .progress(let c):
            d.binding = c.binding
            d.progressStyle = c.style
            d.accent = c.accent
        }
        return d
    }
}

/// Form fields for editing every property of a `ComponentDraft`. Shared
/// between the add flow and CellEditorView.
struct ComponentConfigForm: View {
    @Binding var draft: ComponentDraft
    @State private var showingBindingPicker = false

    var body: some View {
        Group {
            switch draft.kind {
            case .header:
                Section("Header") {
                    TextField("Title", text: $draft.headerTitle)
                    TextField("Subtitle (optional)", text: $draft.headerSubtitle)
                }
            case .appTile:
                Section("App") {
                    Picker("App", selection: $draft.appTileBundleId) {
                        ForEach(uniqueRegistryEntries, id: \.bundleId) { entry in
                            Text(entry.displayName).tag(entry.bundleId)
                        }
                    }
                }
            case .count:
                bindingSection
                Section("Options") {
                    TextField("Caption (optional)", text: $draft.countCaption)
                }
            case .list:
                bindingSection
                Section("Options") {
                    Stepper(value: $draft.listMaxRows, in: 1...10) {
                        Text("Rows shown: \(draft.listMaxRows)")
                    }
                }
            case .metric:
                bindingSection
                Section("Options") {
                    TextField("Caption (optional)", text: $draft.metricCaption)
                }
            case .status:
                bindingSection
            case .progress:
                bindingSection
                Section("Options") {
                    Picker("Style", selection: $draft.progressStyle) {
                        Text("Bar").tag(ProgressStyle.bar)
                        Text("Ring").tag(ProgressStyle.ring)
                    }
                    .pickerStyle(.segmented)
                }
            }
            Section("Accent") {
                Picker("Accent", selection: accentBinding) {
                    Text("From app").tag(AccentPick.fromApp)
                    ForEach(AccentChoice.Token.allCases, id: \.self) { t in
                        Text(t.rawValue.capitalized).tag(AccentPick.token(t))
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    @ViewBuilder
    private var bindingSection: some View {
        Section("Data source") {
            Button {
                showingBindingPicker = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(bindingHeadline)
                            .foregroundStyle(.primary)
                        if let sub = bindingSubtitle {
                            Text(sub)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .sheet(isPresented: $showingBindingPicker) {
                BindingPicker(requiredKind: requiredKind, selection: $draft.binding)
            }
        }
    }

    private var requiredKind: SliceKind {
        // `bindingSection` is only shown for kinds whose requiredSliceKind is non-nil.
        // Force-unwrap is safe because the outer switch guards it.
        switch draft.kind {
        case .count: return .count
        case .list: return .list
        case .metric: return .metric
        case .status: return .status
        case .progress: return .progress
        case .header, .appTile: return .count // unreachable
        }
    }

    private var bindingHeadline: String {
        guard let b = draft.binding else { return "Pick a data source…" }
        // Try to resolve a friendly label from the known catalog first.
        if let known = KnownSliceCatalog.slices(for: b.bundleId).first(where: { $0.sliceId == b.sliceId }) {
            return known.displayName
        }
        return b.sliceId
    }

    private var bindingSubtitle: String? {
        guard let b = draft.binding else { return nil }
        return AppRegistry.default.entry(for: b.bundleId)?.displayName ?? b.bundleId
    }

    private var uniqueRegistryEntries: [AppRegistry.Entry] {
        // Deduplicate by displayName so prod/internal variants collapse in the picker.
        var seen = Set<String>()
        var out: [AppRegistry.Entry] = []
        for e in AppRegistry.default.entries {
            if seen.insert(e.displayName).inserted { out.append(e) }
        }
        return out
    }

    // Bridge AccentChoice's associated-value enum through a flat Hashable enum
    // so SwiftUI's Picker works with a single tag type.
    private enum AccentPick: Hashable {
        case fromApp
        case token(AccentChoice.Token)
    }

    private var accentBinding: Binding<AccentPick> {
        Binding(
            get: {
                switch draft.accent {
                case .fromApp: return .fromApp
                case .token(let t): return .token(t)
                }
            },
            set: { pick in
                switch pick {
                case .fromApp: draft.accent = .fromApp
                case .token(let t): draft.accent = .token(t)
                }
            }
        )
    }
}
