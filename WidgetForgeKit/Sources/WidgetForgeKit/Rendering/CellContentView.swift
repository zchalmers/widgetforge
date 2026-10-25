#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

/// Renders a single cell's card (background, stroke, clip) plus its component
/// body. Extracted from `LayoutRenderer` so both the widget renderer and the
/// editor canvas render cells identically. The caller owns the frame size and
/// offset; this view fills whatever frame it is given.
public struct CellContentView: View {
    public let component: Component
    public let slice: DataSlice?
    public let registry: AppRegistry
    @Environment(\.widgetTheme) private var theme

    public init(component: Component, slice: DataSlice?, registry: AppRegistry) {
        self.component = component
        self.slice = slice
        self.registry = registry
    }

    public var body: some View {
        componentBody
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .themeCard(theme.card)
    }

    @ViewBuilder
    private var componentBody: some View {
        switch component {
        case .header(let c): HeaderView(config: c)
        case .count(let c): CountView(config: c, slice: slice)
        case .metric(let c): MetricView(config: c, slice: slice)
        case .status(let c): StatusView(config: c, slice: slice)
        case .progress(let c): WFProgressView(config: c, slice: slice)
        case .list(let c): ListView(config: c, slice: slice)
        case .appTile(let c): AppTileView(config: c, entry: registry.entry(for: c.bundleId))
        }
    }
}
#endif
