import Foundation

public enum LayoutValidator {
    public static func validate(_ layout: WidgetLayout) throws {
        let cols = layout.family.cols
        let rows = layout.family.rows
        for cell in layout.cells {
            guard cell.span.cols > 0, cell.span.rows > 0 else {
                throw WidgetForgeError.cellOutOfBounds(cell: cell.id, family: layout.family)
            }
            guard cell.origin.col >= 0, cell.origin.row >= 0 else {
                throw WidgetForgeError.cellOutOfBounds(cell: cell.id, family: layout.family)
            }
            guard cell.origin.col + cell.span.cols <= cols,
                  cell.origin.row + cell.span.rows <= rows else {
                throw WidgetForgeError.cellOutOfBounds(cell: cell.id, family: layout.family)
            }
        }
        // Overlap check: two cells overlap if their rectangles intersect.
        let sorted = layout.cells
        for i in 0..<sorted.count {
            for j in (i + 1)..<sorted.count {
                if GridRect.intersects(sorted[i].origin, sorted[i].span,
                                       sorted[j].origin, sorted[j].span) {
                    throw WidgetForgeError.cellOverlap(a: sorted[i].id, b: sorted[j].id)
                }
            }
        }
    }
}
