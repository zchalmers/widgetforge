#if canImport(SwiftUI)
import SwiftUI

/// Renders a `WidgetTheme.Background` as a fill behind all cells. Used by both
/// `LayoutRenderer` (shipped widget) and the editor canvas so they match.
public struct ThemeBackgroundView: View {
    public let background: WidgetTheme.Background
    public init(_ background: WidgetTheme.Background) { self.background = background }

    public var body: some View {
        switch background {
        case .gradient(let top, let bottom):
            LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
        case .diagonalGradient(let from, let to):
            LinearGradient(colors: [from, to], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .solid(let c):
            c
        case .blobs(let base, let blobs):
            GeometryReader { geo in
                ZStack {
                    base
                    ForEach(Array(blobs.enumerated()), id: \.offset) { _, b in
                        Circle()
                            .fill(b.color)
                            .frame(width: geo.size.width * b.radius * 2,
                                   height: geo.size.width * b.radius * 2)
                            .position(x: geo.size.width * b.x, y: geo.size.height * b.y)
                            .blur(radius: geo.size.width * b.radius * 0.5)
                    }
                }
                .drawingGroup()
            }
        }
    }
}

extension View {
    /// Apply a theme's card treatment (fill/material, stroke, corner, shadow) to
    /// a cell's content. `CellContentView` calls this so every cell honors the
    /// active theme.
    @ViewBuilder
    public func themeCard(_ card: WidgetTheme.Card) -> some View {
        let shape = RoundedRectangle(cornerRadius: card.cornerRadius, style: .continuous)
        switch card.style {
        case .none:
            self
        case .flat:
            self.clipShape(shape)
        case .glass:
            self
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.stroke(card.stroke, lineWidth: card.strokeWidth))
                .clipShape(shape)
                .shadow(color: .black.opacity(card.shadowRadius > 0 ? 0.25 : 0),
                        radius: card.shadowRadius)
        case .solid:
            self
                .background(shape.fill(card.fill))
                .overlay(shape.stroke(card.stroke, lineWidth: card.strokeWidth))
                .clipShape(shape)
                .shadow(color: .black.opacity(card.shadowRadius > 0 ? 0.25 : 0),
                        radius: card.shadowRadius)
        }
    }
}
#endif
