import XCTest
@testable import WidgetForgeKit

final class CanvasEditIntentTests: XCTestCase {
    private func cell(_ col: Int, _ row: Int, _ cols: Int, _ rows: Int, id: UUID = UUID()) -> Cell {
        Cell(id: id, origin: GridPoint(col: col, row: row), span: GridSize(cols: cols, rows: rows),
             component: .header(.init(title: "H", subtitle: nil, accent: .fromApp)))
    }

    func testGridRectIntersectsOverlapping() {
        XCTAssertTrue(GridRect.intersects(GridPoint(col: 0, row: 0), GridSize(cols: 2, rows: 2),
                                          GridPoint(col: 1, row: 1), GridSize(cols: 1, rows: 1)))
    }

    func testGridRectAdjacentDoesNotIntersect() {
        // Share an edge at col 2 => half-open, so no overlap.
        XCTAssertFalse(GridRect.intersects(GridPoint(col: 0, row: 0), GridSize(cols: 2, rows: 1),
                                           GridPoint(col: 2, row: 0), GridSize(cols: 1, rows: 1)))
    }

    func testResizeGrowsWithinBounds() {
        // large = 4x4. A 1x1 at (0,0), grow by (+1,+1) => 2x2, no siblings.
        let c = cell(0, 0, 1, 1)
        let span = CanvasEditIntent.resize(cell: c, delta: (1, 1), family: .large, siblings: [])
        XCTAssertEqual(span, GridSize(cols: 2, rows: 2))
    }

    func testResizeClampsToFamilyBounds() {
        // 1x1 at (2,2) in large (4x4). Grow by (+5,+5) => clamped to 2x2 (fits 2..4).
        let c = cell(2, 2, 1, 1)
        let span = CanvasEditIntent.resize(cell: c, delta: (5, 5), family: .large, siblings: [])
        XCTAssertEqual(span, GridSize(cols: 2, rows: 2))
    }

    func testResizeNeverBelowOneByOne() {
        let c = cell(0, 0, 2, 2)
        let span = CanvasEditIntent.resize(cell: c, delta: (-9, -9), family: .large, siblings: [])
        XCTAssertEqual(span, GridSize(cols: 1, rows: 1))
    }

    func testResizeBlockedBySiblingStopsAtLargestLegal() {
        // Growing cell at (0,0) 1x1; sibling occupies col 2 => can grow to 2 cols max.
        let c = cell(0, 0, 1, 1)
        let blocker = cell(2, 0, 1, 4)
        let span = CanvasEditIntent.resize(cell: c, delta: (3, 0), family: .large, siblings: [blocker])
        XCTAssertEqual(span, GridSize(cols: 2, rows: 1))
    }

    func testSnappedMoveLegalReturnsOrigin() {
        let c = cell(0, 0, 1, 1)
        let dest = GridPoint(col: 3, row: 3)
        XCTAssertEqual(CanvasEditIntent.snappedMove(cell: c, to: dest, family: .large, siblings: []), dest)
    }

    func testSnappedMoveOntoSiblingReturnsNil() {
        let c = cell(0, 0, 1, 1)
        let blocker = cell(1, 1, 1, 1)
        XCTAssertNil(CanvasEditIntent.snappedMove(cell: c, to: GridPoint(col: 1, row: 1),
                                                  family: .large, siblings: [blocker]))
    }

    func testCanPlaceRejectsOutOfBounds() {
        XCTAssertFalse(CanvasEditIntent.canPlace(span: GridSize(cols: 2, rows: 1),
                                                 at: GridPoint(col: 3, row: 0),
                                                 family: .large, siblings: [], excluding: UUID()))
    }
}
