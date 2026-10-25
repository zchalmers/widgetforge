#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

public struct LayoutRenderer: View {
    public let layout: WidgetLayout
    public let context: RenderContext
    @Environment(\.widgetTheme) private var theme

    public init(layout: WidgetLayout, context: RenderContext) {
        self.layout = layout
        self.context = context
    }

    public var body: some View {
        GeometryReader { geo in
            let cols = CGFloat(layout.family.cols)
            let rows = CGFloat(layout.family.rows)
            let cellW = geo.size.width / cols
            let cellH = geo.size.height / rows
            ZStack(alignment: .topLeading) {
                background
                ForEach(layout.cells) { cell in
                    cellView(cell)
                        .frame(width: cellW * CGFloat(cell.span.cols),
                               height: cellH * CGFloat(cell.span.rows))
                        .offset(x: cellW * CGFloat(cell.origin.col),
                                y: cellH * CGFloat(cell.origin.row))
                        .padding(theme.cellSpacing)
                }
            }
        }
    }

    @ViewBuilder
    private var background: some View {
        // A layout's stored background overrides the theme canvas only when it
        // is not the plain system default; otherwise the theme paints the canvas.
        switch layout.background {
        case .system:
            ThemeBackgroundView(theme.background)
        case .accentHex(let hex):
            DesignSystem.color(fromHex: hex)
        case .clear:
            Color.clear
        }
    }

    @ViewBuilder
    private func cellView(_ cell: Cell) -> some View {
        let slice: DataSlice? = cell.boundBinding.flatMap { context.slice(for: $0) }
        CellContentView(component: cell.component, slice: slice, registry: context.registry)
    }
}
#endif
