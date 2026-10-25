import Foundation

/// Home-screen-style reflow for a move: the dragged cell is anchored at its
/// drop target and the other cells flow around it. Cells that do not collide
/// with the moved cell keep their exact spot (minimal disruption); only the
/// displaced ones are re-packed into the first free slot in reading order.
///
/// Pure and Foundation-only so it can be unit-tested without SwiftUI. Overlap
/// testing uses the shared `GridRect` helper indirectly via a local occupancy
/// grid (cheaper than pairwise here since we place one cell at a time).
public enum CanvasReflow {
    /// Returns a new arrangement with `movingId` placed at `target` and every
    /// other cell packed legally around it, or `nil` if the moved cell would
    /// be out of bounds or the others cannot all be re-packed (caller should
    /// then leave the layout unchanged so the cell snaps back).
    public static func place(cells: [Cell],
                             moving movingId: UUID,
                             to target: GridPoint,
                             family: LayoutFamily) -> [Cell]? {
        guard var moving = cells.first(where: { $0.id == movingId }) else { return nil }
        moving.origin = target
        // The moved cell must fit in bounds at its target on its own.
        guard target.col >= 0, target.row >= 0,
              target.col + moving.span.cols <= family.cols,
              target.row + moving.span.rows <= family.rows else { return nil }

        var occ = Array(repeating: Array(repeating: false, count: family.cols),
                        count: family.rows)

        func fits(_ origin: GridPoint, _ span: GridSize) -> Bool {
            guard origin.col >= 0, origin.row >= 0,
                  origin.col + span.cols <= family.cols,
                  origin.row + span.rows <= family.rows else { return false }
            for r in origin.row..<(origin.row + span.rows) {
                for c in origin.col..<(origin.col + span.cols) where occ[r][c] {
                    return false
                }
            }
            return true
        }
        func mark(_ origin: GridPoint, _ span: GridSize) {
            for r in origin.row..<(origin.row + span.rows) {
                for c in origin.col..<(origin.col + span.cols) {
                    occ[r][c] = true
                }
            }
        }

        mark(target, moving.span)
        var result = [moving]

        // Others in reading order so re-packing is stable and preserves the
        // rough top-to-bottom, left-to-right arrangement.
        let others = cells
            .filter { $0.id != movingId }
            .sorted { ($0.origin.row, $0.origin.col) < ($1.origin.row, $1.origin.col) }

        for var other in others {
            // Prefer the cell's current spot: only displace cells that actually
            // collide with the moved cell (or with an already-displaced cell).
            if fits(other.origin, other.span) {
                mark(other.origin, other.span)
                result.append(other)
                continue
            }
            // Displaced: drop into the first free legal slot, reading order.
            var placed = false
            search: for r in 0..<family.rows {
                for c in 0..<family.cols {
                    let candidate = GridPoint(col: c, row: r)
                    if fits(candidate, other.span) {
                        other.origin = candidate
                        mark(candidate, other.span)
                        result.append(other)
                        placed = true
                        break search
                    }
                }
            }
            if !placed { return nil }
        }
        return result
    }
}
