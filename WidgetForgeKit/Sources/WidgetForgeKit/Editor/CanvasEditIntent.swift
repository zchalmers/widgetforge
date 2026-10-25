import Foundation

/// Pure decision logic for canvas edits (move / resize). Delegates overlap
/// testing to the shared `GridRect` helper so it stays consistent with
/// `LayoutValidator`. The app-target `PlacementSolver` is a separate copy and
/// is out of scope for this plan.
public enum CanvasEditIntent {
    /// Largest legal span <= (cell.span + delta), clamped to >=1x1, to family
    /// bounds at the cell's current origin, and to no overlap with siblings.
    public static func resize(cell: Cell,
                              delta: (dCols: Int, dRows: Int),
                              family: LayoutFamily,
                              siblings: [Cell]) -> GridSize {
        let requestedCols = max(1, cell.span.cols + delta.dCols)
        let requestedRows = max(1, cell.span.rows + delta.dRows)
        let maxCols = family.cols - cell.origin.col
        let maxRows = family.rows - cell.origin.row
        var bestCols = 1
        var bestRows = 1
        // Grow greedily to the largest cols x rows that fits and does not overlap.
        for cols in stride(from: min(requestedCols, maxCols), through: 1, by: -1) {
            for rows in stride(from: min(requestedRows, maxRows), through: 1, by: -1) {
                let span = GridSize(cols: cols, rows: rows)
                if canPlace(span: span, at: cell.origin, family: family,
                            siblings: siblings, excluding: cell.id) {
                    if cols * rows > bestCols * bestRows {
                        bestCols = cols; bestRows = rows
                    }
                }
            }
        }
        return GridSize(cols: bestCols, rows: bestRows)
    }

    /// Returns `origin` if a move there is legal, else nil (caller snaps back).
    public static func snappedMove(cell: Cell,
                                   to origin: GridPoint,
                                   family: LayoutFamily,
                                   siblings: [Cell]) -> GridPoint? {
        canPlace(span: cell.span, at: origin, family: family,
                 siblings: siblings, excluding: cell.id) ? origin : nil
    }

    public static func canPlace(span: GridSize,
                                at origin: GridPoint,
                                family: LayoutFamily,
                                siblings: [Cell],
                                excluding id: UUID) -> Bool {
        guard span.cols > 0, span.rows > 0 else { return false }
        guard origin.col >= 0, origin.row >= 0 else { return false }
        guard origin.col + span.cols <= family.cols,
              origin.row + span.rows <= family.rows else { return false }
        return siblings
            .filter { $0.id != id }
            .allSatisfy { !GridRect.intersects($0.origin, $0.span, origin, span) }
    }
}
