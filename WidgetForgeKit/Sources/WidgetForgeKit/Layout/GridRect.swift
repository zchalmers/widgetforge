import Foundation

/// Half-open rectangle overlap test on the integer layout grid. Single source
/// of truth for "do these two cells overlap", used by `LayoutValidator` and
/// `CanvasEditIntent`. Adjacent cells that merely share an edge do NOT overlap.
public enum GridRect {
    public static func intersects(_ aOrigin: GridPoint, _ aSpan: GridSize,
                                  _ bOrigin: GridPoint, _ bSpan: GridSize) -> Bool {
        let ax1 = aOrigin.col, ax2 = aOrigin.col + aSpan.cols
        let ay1 = aOrigin.row, ay2 = aOrigin.row + aSpan.rows
        let bx1 = bOrigin.col, bx2 = bOrigin.col + bSpan.cols
        let by1 = bOrigin.row, by2 = bOrigin.row + bSpan.rows
        return ax1 < bx2 && bx1 < ax2 && ay1 < by2 && by1 < ay2
    }
}
