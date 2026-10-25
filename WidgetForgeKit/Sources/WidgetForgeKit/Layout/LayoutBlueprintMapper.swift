import Foundation

/// Pure, Foundation-Models-free mapper that turns flat "blueprint" cell data
/// (plain Ints + string kind/binding) into validated `WidgetForgeKit` types.
/// Lives in the kit — NOT the app target — so it is unit-testable via SPM
/// without importing FoundationModels or AppIntents.
///
/// `AuthorLayoutIntent` (app target) owns the `@Generable` DTO; it flattens
/// the model output into `LayoutBlueprintInput` and calls `build(...)` here.
public enum LayoutBlueprintMapper {

    public struct CellInput: Sendable, Equatable {
        public var col: Int
        public var row: Int
        public var cols: Int
        public var rows: Int
        /// One of Component.Kind.rawValue: count/list/metric/status/progress/header.
        public var kind: String
        /// bundleId to bind to (ignored for header). Empty allowed for header.
        public var bundleId: String
        /// sliceId to bind to (ignored for header).
        public var sliceId: String
        /// Optional caption / title text.
        public var text: String?

        public init(col: Int, row: Int, cols: Int, rows: Int,
                    kind: String, bundleId: String, sliceId: String, text: String?) {
            self.col = col; self.row = row; self.cols = cols; self.rows = rows
            self.kind = kind; self.bundleId = bundleId; self.sliceId = sliceId; self.text = text
        }
    }

    public struct LayoutBlueprintInput: Sendable, Equatable {
        public var name: String
        public var family: LayoutFamily
        public var cells: [CellInput]
        public init(name: String, family: LayoutFamily, cells: [CellInput]) {
            self.name = name; self.family = family; self.cells = cells
        }
    }

    public enum MapError: Error, Equatable {
        case noMappableCells
        case unknownKind(String)
    }

    /// Build a validated `WidgetLayout` from a blueprint. Clamps out-of-range
    /// geometry to the family grid and drops cells that still don't fit rather
    /// than failing the whole layout — the model's geometry is advisory.
    /// Throws `MapError.noMappableCells` if nothing survives, and rethrows
    /// `LayoutValidator` errors if the assembled set still fails validation
    /// (should not happen after per-cell fitting, but we never write unvalidated).
    public static func build(_ input: LayoutBlueprintInput,
                             id: UUID = UUID(),
                             now: Date = Date()) throws -> WidgetLayout {
        let family = input.family
        var placed: [Cell] = []

        for raw in input.cells {
            guard let component = component(for: raw) else { continue }

            // Clamp geometry into the family grid.
            let cols = min(max(1, raw.cols), family.cols)
            let rows = min(max(1, raw.rows), family.rows)
            let maxCol = family.cols - cols
            let maxRow = family.rows - rows
            let col = min(max(0, raw.col), max(0, maxCol))
            let row = min(max(0, raw.row), max(0, maxRow))

            let candidate = Cell(origin: GridPoint(col: col, row: row),
                                 span: GridSize(cols: cols, rows: rows),
                                 component: component)

            // Only keep the cell if it doesn't overlap something already placed.
            if fits(candidate, in: placed) {
                placed.append(candidate)
            } else if let slot = firstFreeOrigin(cols: cols, rows: rows, family: family, existing: placed) {
                placed.append(Cell(origin: slot,
                                   span: GridSize(cols: cols, rows: rows),
                                   component: component))
            }
            // else: no room — drop this cell.
        }

        guard !placed.isEmpty else { throw MapError.noMappableCells }

        let layout = WidgetLayout(id: id,
                                  name: input.name.isEmpty ? "New \(family.rawValue)" : input.name,
                                  family: family,
                                  cells: placed,
                                  background: .system,
                                  createdAt: now,
                                  updatedAt: now)
        try LayoutValidator.validate(layout)
        return layout
    }

    // MARK: - Component assembly

    private static func component(for raw: CellInput) -> Component? {
        let binding = DataBinding(bundleId: raw.bundleId, sliceId: raw.sliceId)
        switch raw.kind {
        case "count":
            return .count(CountConfig(binding: binding, caption: raw.text, accent: .fromApp))
        case "list":
            return .list(ListConfig(binding: binding, maxRows: 4, accent: .fromApp))
        case "metric":
            return .metric(MetricConfig(binding: binding, caption: raw.text, accent: .fromApp))
        case "status":
            return .status(StatusConfig(binding: binding, accent: .fromApp))
        case "progress":
            return .progress(ProgressConfig(binding: binding, style: .bar, accent: .fromApp))
        case "header":
            return .header(HeaderConfig(title: raw.text ?? "WidgetForge", subtitle: nil, accent: .fromApp))
        default:
            return nil
        }
    }

    // MARK: - Geometry

    private static func fits(_ cell: Cell, in existing: [Cell]) -> Bool {
        existing.allSatisfy { !overlaps($0, cell) }
    }

    private static func overlaps(_ a: Cell, _ b: Cell) -> Bool {
        let ax2 = a.origin.col + a.span.cols, ay2 = a.origin.row + a.span.rows
        let bx2 = b.origin.col + b.span.cols, by2 = b.origin.row + b.span.rows
        return a.origin.col < bx2 && b.origin.col < ax2 && a.origin.row < by2 && b.origin.row < ay2
    }

    private static func firstFreeOrigin(cols: Int, rows: Int, family: LayoutFamily, existing: [Cell]) -> GridPoint? {
        guard cols <= family.cols, rows <= family.rows else { return nil }
        for r in 0...(family.rows - rows) {
            for c in 0...(family.cols - cols) {
                let candidate = Cell(origin: GridPoint(col: c, row: r),
                                     span: GridSize(cols: cols, rows: rows),
                                     component: .header(HeaderConfig(title: "", subtitle: nil, accent: .fromApp)))
                if fits(candidate, in: existing) { return GridPoint(col: c, row: r) }
            }
        }
        return nil
    }
}
