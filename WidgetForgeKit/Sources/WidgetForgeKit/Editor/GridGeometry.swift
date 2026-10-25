import CoreGraphics

/// Converts between pixel space (drag offsets/translations on the editor
/// canvas) and grid units for a fixed-dimension `LayoutFamily`. Pure value
/// type: no SwiftUI, no persistence. All snapping is rounding to the nearest
/// grid line, then clamping so the result stays in bounds.
public struct GridGeometry: Equatable, Sendable {
    public let family: LayoutFamily
    public let size: CGSize

    public init(family: LayoutFamily, size: CGSize) {
        self.family = family
        self.size = size
    }

    public var cellWidth: CGFloat { size.width / CGFloat(family.cols) }
    public var cellHeight: CGFloat { size.height / CGFloat(family.rows) }

    /// Nearest in-bounds origin for a cell of `span` whose top-left has been
    /// dragged to `pixelOffset` (measured from the canvas top-left). Clamped so
    /// origin + span never exceeds the family grid.
    public func snappedOrigin(pixelOffset: CGSize, span: GridSize) -> GridPoint {
        let rawCol = Int((pixelOffset.width / cellWidth).rounded())
        let rawRow = Int((pixelOffset.height / cellHeight).rounded())
        let maxCol = max(0, family.cols - span.cols)
        let maxRow = max(0, family.rows - span.rows)
        return GridPoint(col: min(max(0, rawCol), maxCol),
                         row: min(max(0, rawRow), maxRow))
    }

    /// Grid-unit delta for a resize drag of `pixelTranslation`.
    public func spanDelta(pixelTranslation: CGSize) -> (dCols: Int, dRows: Int) {
        (dCols: Int((pixelTranslation.width / cellWidth).rounded()),
         dRows: Int((pixelTranslation.height / cellHeight).rounded()))
    }

    /// Pixel rect occupied by a grid cell at `origin` spanning `span`.
    public func pixelFrame(origin: GridPoint, span: GridSize) -> CGRect {
        CGRect(x: cellWidth * CGFloat(origin.col),
               y: cellHeight * CGFloat(origin.row),
               width: cellWidth * CGFloat(span.cols),
               height: cellHeight * CGFloat(span.rows))
    }
}
