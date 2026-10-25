import SwiftUI
import WidgetForgeKit

/// Root view rendered by every widget kind. Wraps `LayoutRenderer` with a
/// container background (Liquid Glass compatible), handles empty-manifest and
/// missing-layout error states, and provides tap routing via `.widgetURL` for
/// small widgets or `Link` for medium+.
struct WidgetRootView: View {
    let entry: LayoutEntry
    let role: WidgetRole

    var body: some View {
        Group {
            if entry.manifests.isEmpty {
                WidgetErrorView(
                    kind: role.widgetKind,
                    reason: .noManifests,
                    layoutId: entry.layout.id
                )
            } else {
                LayoutRenderer(
                    layout: entry.layout,
                    context: RenderContext(
                        pool: SlicePool(entry.manifests),
                        registry: .default,
                        now: entry.date
                    )
                )
                .widgetTheme(theme)
            }
        }
        .containerBackground(for: .widget) {
            ThemeBackgroundView(theme.background)
        }
        .widgetURL(primaryDeepLink)
    }

    /// The resolved theme for the entry's layout (classic if none/unknown).
    private var theme: WidgetTheme {
        ThemeCatalog.theme(id: entry.layout.themeId)
    }

    /// Small widgets use widgetURL for the whole surface. Medium and larger
    /// use per-cell links via LayoutRenderer's future extensions, but we set
    /// widgetURL as a fallback for the entire tile too.
    private var primaryDeepLink: URL {
        if entry.manifests.isEmpty {
            return DeepLinkBuilder.recover(
                kind: role.widgetKind,
                reason: .noManifests,
                layoutId: entry.layout.id
            )
        }
        let pool = SlicePool(entry.manifests)
        return entry.layout.primaryDeepLink(
            pool: pool,
            registry: .default,
            kind: role.widgetKind
        )
    }
}
