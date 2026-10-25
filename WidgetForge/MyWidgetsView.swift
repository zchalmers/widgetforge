import SwiftUI
import WidgetForgeKit
import WidgetKit
import ThemeKitSwiftUICore
import ThemeKitThemeManager

/// Lists saved layouts and offers preview + delete. Tapping a row opens the
/// preview sheet where users can rename the layout or delete it. Editor UI is
/// out of scope for the prototype — widgets already resolve stored layouts by id.
struct MyWidgetsView: View {
    @State private var entries: [LayoutStore.IndexEntry] = []
    @State private var previewLayoutId: UUID?
    @Environment(AppRouter.self) private var router

    private let store = LayoutStore()

    var body: some View {
        NavigationStack {
            List {
                if entries.isEmpty {
                    IllustratedMessage(
                        detailImage: Image(systemName: "rectangle.stack"),
                        title: AttributedString("No Layouts Yet"),
                        description: AttributedString("Default layouts get seeded on first launch. Pull to refresh, or long-press an empty spot on your Home Screen and pick Widget Small/Medium/Large/XL to add the widget itself."),
                        detailImageSize: .large,
                        contentAlignment: .center
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } else {
                    Section("Saved layouts") {
                        ForEach(entries, id: \.id) { entry in
                            Button {
                                previewLayoutId = entry.id
                            } label: {
                                LayoutRow(entry: entry)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("WidgetForge")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: Binding(
                get: { previewLayoutId.map(IdWrap.init) },
                set: { previewLayoutId = $0?.id }
            )) { wrap in
                LayoutPreviewSheet(layoutId: wrap.id)
            }
            .task { refresh() }
            .refreshable { refresh() }
        }
    }

    private func refresh() {
        entries = store.readIndex().sorted { $0.updatedAt > $1.updatedAt }
    }

    private func delete(at offsets: IndexSet) {
        for idx in offsets {
            try? store.delete(id: entries[idx].id)
        }
        WidgetCenter.shared.reloadAllTimelines()
        refresh()
    }
}

struct IdWrap: Identifiable, Hashable {
    let id: UUID
}

private struct LayoutRow: View {
    let entry: LayoutStore.IndexEntry

    var body: some View {
        ObjectItem(
            title: AttributedString(entry.name),
            subtitle: AttributedString(entry.family.rawValue.capitalized + " layout"),
            status: .icon(Image(systemName: "chevron.right")),
            detailImage: Image(systemName: iconName)
        )
        .detailImageStyle { config in
            config.detailImage
                .font(.themeKit(forTextStyle: .title2))
                .foregroundStyle(Color.preferredColor(.tintColor))
                .frame(width: 32)
        }
        .statusStyle { config in
            config.status
                .foregroundStyle(Color.preferredColor(.tertiaryLabel))
        }
        .contentShape(Rectangle())
    }

    private var iconName: String {
        switch entry.family {
        case .small: return "square.dashed"
        case .medium: return "rectangle.dashed"
        case .large: return "square.grid.2x2"
        case .extraLarge: return "square.grid.3x2"
        case .xlPortrait: return "square.grid.3x3"
        }
    }
}

struct LayoutPreviewSheet: View {
    let layoutId: UUID
    @Environment(\.dismiss) private var dismiss

    private let store = LayoutStore()
    @State private var loaded: WidgetLayout?
    @State private var editing = false
    @State private var reloadKey = UUID()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let layout = loaded {
                    let ctx = RenderContext(pool: SlicePool(SampleData.merged(withReal: ManifestStore().readAll())), registry: .default)
                    LayoutRenderer(layout: layout, context: ctx)
                        .widgetTheme(ThemeCatalog.theme(id: layout.themeId))
                        .frame(width: 320, height: previewHeight(for: layout.family))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding()
                        .id(reloadKey)
                    Text(layout.name)
                        .font(.headline)
                    Text("\(layout.cells.count) cell\(layout.cells.count == 1 ? "" : "s") · \(layout.family.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Tap Edit to compose the widget. Add it to your Home Screen from the widget picker (long-press an empty spot → Widget Small/Medium/Large/XL).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    ContentUnavailableView("Layout unavailable", systemImage: "questionmark.folder")
                }
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { editing = true }
                        .disabled(loaded == nil)
                }
            }
            .task {
                loaded = try? store.read(id: layoutId)
            }
            .fullScreenCover(isPresented: $editing) {
                if let l = loaded {
                    LayoutEditorSheet(original: l) { saved in
                        loaded = saved
                        reloadKey = UUID()
                    }
                }
            }
        }
    }

    private func previewHeight(for family: LayoutFamily) -> CGFloat {
        switch family {
        case .small: return 320
        case .medium: return 160
        case .large: return 320
        case .extraLarge, .xlPortrait: return 480
        }
    }
}
