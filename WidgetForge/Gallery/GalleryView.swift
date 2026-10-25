import SwiftUI
import WidgetForgeKit
import WidgetKit
import ThemeKitSwiftUICore
import ThemeKitThemeManager

struct GalleryView: View {
    @State private var model = GalleryViewModel()
    @State private var previewLayoutId: UUID?
    @State private var showingNewWidget = false

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PersonaChipRow(selection: $model.selectedPersona)

                    if !model.yours.isEmpty {
                        section(title: "Yours") {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(model.yours.compactMap { model.layout(for: $0) }) { layout in
                                    GalleryCard(layout: layout, context: model.renderContext) {
                                        previewLayoutId = layout.id
                                    }
                                }
                            }
                        }
                    }

                    if model.browseGroups.isEmpty && model.yours.isEmpty {
                        emptyState
                    } else {
                        ForEach(model.browseGroups, id: \.persona) { group in
                            section(title: group.persona.displayName) {
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(group.layouts) { layout in
                                        GalleryCard(layout: layout, context: model.renderContext) {
                                            previewLayoutId = layout.id
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Gallery")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewWidget = true
                    } label: {
                        Label("New Widget", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewWidget) {
                NewWidgetSheet { model.refresh() }
            }
            .sheet(item: Binding(
                get: { previewLayoutId.map(IdWrap.init) },
                set: { previewLayoutId = $0?.id }
            )) { wrap in
                LayoutPreviewSheet(layoutId: wrap.id)
            }
            .task { model.refresh() }
            .refreshable { model.refresh() }
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.themeKit(forTextStyle: .footnote, weight: .semibold))
                .foregroundStyle(Color.preferredColor(.secondaryLabel))
                .padding(.horizontal, 16)
            content()
                .padding(.horizontal, 16)
        }
    }

    private var emptyState: some View {
        IllustratedMessage(
            detailImage: Image(systemName: "square.grid.2x2"),
            title: AttributedString("No layouts for this filter"),
            description: AttributedString("Pick a different persona, or tap + to create a new widget."),
            detailImageSize: .large,
            contentAlignment: .center
        )
        .padding(.top, 40)
    }
}
