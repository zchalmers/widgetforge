import SwiftUI
import WidgetForgeKit

/// A live theme picker: shows every `ThemeCatalog` theme as a small preview of
/// the ACTUAL layout being edited (so you see your own widget in each style),
/// and reports the chosen theme id. Presented as a sheet from the editor.
struct ThemePicker: View {
    let layout: WidgetLayout
    let selectedId: String?
    var onPick: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var manifests: [AppCapabilityManifest] = []

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(ThemeCatalog.all) { theme in
                        Button {
                            onPick(theme.id)
                            dismiss()
                        } label: {
                            VStack(spacing: 6) {
                                LayoutRenderer(
                                    layout: layout,
                                    context: RenderContext(pool: SlicePool(manifests), registry: .default)
                                )
                                .widgetTheme(theme)
                                .frame(width: 150, height: 94)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(theme.id == selectedId ? DesignSystem.suiteAccent : DesignSystem.cardStroke,
                                                lineWidth: theme.id == selectedId ? 3 : 1)
                                )
                                HStack(spacing: 4) {
                                    if theme.id == selectedId {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption2)
                                            .foregroundStyle(DesignSystem.suiteAccent)
                                    }
                                    Text(theme.name)
                                        .font(.themeKit(forTextStyle: .caption1, weight: theme.id == selectedId ? .semibold : .regular))
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task { manifests = SampleData.merged(withReal: ManifestStore().readAll()) }
        }
    }
}
