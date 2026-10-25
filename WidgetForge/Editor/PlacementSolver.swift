import Foundation
import WidgetForgeKit

/// Pure helpers used by the editor UI to place cells without violating
/// `LayoutValidator` — encapsulates the same overlap/bounds math as the
/// validator, but exposed as a query API instead of a throwing check.
enum PlacementSolver {
    /// Suggested default span for a newly added component of the given kind.
    /// Chosen so the added cell has room to render but stays small enough to
    /// fit alongside a header in most families.
    static func defaultSpan(for kind: Component.Kind, family: LayoutFamily) -> GridSize {
        switch kind {
        case .header:
            // Header always spans full width, one row tall.
            return GridSize(cols: family.cols, rows: 1)
        case .list:
            // List needs vertical room. On small (2x2) fall back to a full row;
            // on medium fill row 1; on larger families give at least 2 rows.
            let rows = min(max(2, family.rows - 1), family.rows)
            return GridSize(cols: family.cols, rows: rows)
        case .count, .metric, .status, .progress, .appTile:
            // Single-cell defaults. `small` uses 1x1; larger families use 2x1
            // so numbers/metrics can breathe.
            let cols = family.cols >= 4 ? 2 : 1
            return GridSize(cols: cols, rows: 1)
        }
    }

    /// Every legal (origin, span) placement for `span` in `family`, given the
    /// already-placed `existing` cells. When `excluding` is non-nil that cell
    /// is treated as absent so the caller can re-place an existing cell.
    /// Sorted top-to-bottom, left-to-right for stable UI listing.
    static func legalOrigins(span: GridSize,
                             family: LayoutFamily,
                             existing: [Cell],
                             excluding: UUID? = nil) -> [GridPoint] {
        guard span.cols > 0, span.rows > 0 else { return [] }
        guard span.cols <= family.cols, span.rows <= family.rows else { return [] }

        let obstacles = existing.filter { $0.id != excluding }
        var out: [GridPoint] = []
        for row in 0...(family.rows - span.rows) {
            for col in 0...(family.cols - span.cols) {
                let candidate = GridPoint(col: col, row: row)
                let fits = obstacles.allSatisfy { !rectsIntersect($0.origin, $0.span, candidate, span) }
                if fits { out.append(candidate) }
            }
        }
        return out
    }

    /// True when placing `span` at `origin` in `family` would pass validation.
    static func canPlace(span: GridSize,
                         at origin: GridPoint,
                         family: LayoutFamily,
                         existing: [Cell],
                         excluding: UUID? = nil) -> Bool {
        guard span.cols > 0, span.rows > 0 else { return false }
        guard origin.col >= 0, origin.row >= 0 else { return false }
        guard origin.col + span.cols <= family.cols,
              origin.row + span.rows <= family.rows else { return false }
        let obstacles = existing.filter { $0.id != excluding }
        return obstacles.allSatisfy { !rectsIntersect($0.origin, $0.span, origin, span) }
    }

    private static func rectsIntersect(_ aOrigin: GridPoint, _ aSpan: GridSize,
                                       _ bOrigin: GridPoint, _ bSpan: GridSize) -> Bool {
        let ax1 = aOrigin.col, ax2 = aOrigin.col + aSpan.cols
        let ay1 = aOrigin.row, ay2 = aOrigin.row + aSpan.rows
        let bx1 = bOrigin.col, bx2 = bOrigin.col + bSpan.cols
        let by1 = bOrigin.row, by2 = bOrigin.row + bSpan.rows
        return ax1 < bx2 && bx1 < ax2 && ay1 < by2 && by1 < ay2
    }
}

extension Component.Kind {
    /// Short label used in kind pickers.
    var displayName: String {
        switch self {
        case .count: return "Count"
        case .list: return "List"
        case .metric: return "Metric"
        case .status: return "Status"
        case .progress: return "Progress"
        case .header: return "Header"
        case .appTile: return "App tile"
        }
    }

    var symbolName: String {
        switch self {
        case .count: return "number.circle.fill"
        case .list: return "list.bullet.rectangle"
        case .metric: return "chart.line.uptrend.xyaxis"
        case .status: return "circle.hexagongrid.fill"
        case .progress: return "chart.pie.fill"
        case .header: return "textformat.size"
        case .appTile: return "app.badge"
        }
    }

    var summary: String {
        switch self {
        case .count: return "A big integer with optional caption."
        case .list: return "Top rows of items from an app."
        case .metric: return "Numeric value with optional unit and trend."
        case .status: return "Colored badge with short text."
        case .progress: return "Ring or bar showing 0–100%."
        case .header: return "Static title and subtitle. No data binding."
        case .appTile: return "Icon + display name for an app. No data binding."
        }
    }
}
