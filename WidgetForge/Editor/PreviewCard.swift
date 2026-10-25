import SwiftUI
import WidgetForgeKit

/// Live-rendered preview of a draft layout using the same LayoutRenderer the
/// widget uses. Fills not-yet-published apps with sample data (real data always
/// wins) so the preview shows what a layout does before the user commits to it.
/// Sized to a fixed height chosen per family so proportions match Home Screen.
struct PreviewCard: View {
    let layout: WidgetLayout
    @State private var manifests: [AppCapabilityManifest] = []

    var body: some View {
        LayoutRenderer(
            layout: layout,
            context: RenderContext(pool: SlicePool(manifests), registry: .default)
        )
        .widgetTheme(ThemeCatalog.theme(id: layout.themeId))
        .frame(width: previewWidth, height: previewHeight)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(DesignSystem.cardStroke, lineWidth: 1)
        )
        .task { manifests = SampleData.merged(withReal: ManifestStore().readAll()) }
    }

    private var previewWidth: CGFloat {
        // Match iOS widget proportions loosely for editor use.
        switch layout.family {
        case .small: return 170
        case .medium: return 340
        case .large: return 340
        case .extraLarge, .xlPortrait: return 340
        }
    }

    private var previewHeight: CGFloat {
        switch layout.family {
        case .small: return 170
        case .medium: return 160
        case .large: return 340
        case .extraLarge: return 340
        case .xlPortrait: return 460
        }
    }
}
