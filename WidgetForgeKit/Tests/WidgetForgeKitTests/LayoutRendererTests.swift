#if canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import WidgetForgeKit

final class LayoutRendererTests: XCTestCase {
    func testConstructsEveryFamily() {
        for family in LayoutFamily.allCases {
            let layout = LayoutStore.defaultLayout(for: family)
            let ctx = RenderContext(pool: SlicePool([]), registry: AppRegistry.default)
            _ = LayoutRenderer(layout: layout, context: ctx).body
        }
    }

    func testRendersEveryComponentKindWithoutCrash() {
        let binding = DataBinding(bundleId: "com.example.Dashboard", sliceId: "s")
        let cells: [Cell] = [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(.init(title: "H", subtitle: nil, accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 1, rows: 1),
                 component: .count(.init(binding: binding, caption: "P", accent: .fromApp))),
            Cell(origin: GridPoint(col: 1, row: 1), span: GridSize(cols: 1, rows: 1),
                 component: .metric(.init(binding: binding, caption: "R", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 1, rows: 1),
                 component: .status(.init(binding: binding, accent: .fromApp))),
            Cell(origin: GridPoint(col: 3, row: 1), span: GridSize(cols: 1, rows: 1),
                 component: .progress(.init(binding: binding, style: .ring, accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 2, rows: 2),
                 component: .list(.init(binding: binding, maxRows: 3, accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 2), span: GridSize(cols: 2, rows: 2),
                 component: .appTile(.init(bundleId: "com.example.Dashboard", accent: .fromApp)))
        ]
        let layout = WidgetLayout(name: "kitchen", family: .large,
                                  cells: cells, background: .system,
                                  createdAt: Date(timeIntervalSince1970: 0),
                                  updatedAt: Date(timeIntervalSince1970: 0))
        XCTAssertNoThrow(try LayoutValidator.validate(layout))
        let ctx = RenderContext(pool: SlicePool([]), registry: AppRegistry.default)
        _ = LayoutRenderer(layout: layout, context: ctx).body
    }
}
#endif
