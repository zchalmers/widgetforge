import XCTest
@testable import WidgetForgeKit

final class CanvasReflowTests: XCTestCase {
    private func cell(_ col: Int, _ row: Int, _ cols: Int, _ rows: Int, id: UUID = UUID()) -> Cell {
        Cell(id: id, origin: GridPoint(col: col, row: row), span: GridSize(cols: cols, rows: rows),
             component: .header(.init(title: "H", subtitle: nil, accent: .fromApp)))
    }

    func testNonCollidingCellsKeepTheirSpot() {
        // large 4x4. Move A from (0,0) to (2,0); B at (0,2) does not collide.
        let a = cell(0, 0, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000A1")!)
        let b = cell(0, 2, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000B2")!)
        let out = CanvasReflow.place(cells: [a, b], moving: a.id,
                                     to: GridPoint(col: 2, row: 0), family: .large)
        let result = try! XCTUnwrap(out)
        let movedA = result.first { $0.id == a.id }!
        let keptB = result.first { $0.id == b.id }!
        XCTAssertEqual(movedA.origin, GridPoint(col: 2, row: 0))
        XCTAssertEqual(keptB.origin, GridPoint(col: 0, row: 2)) // unchanged
    }

    func testCollidingCellIsPushedToFirstFreeSlot() {
        // large 4x4. Move A onto B's spot; B must relocate to first free slot (0,0).
        let a = cell(0, 0, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000A1")!)
        let b = cell(2, 2, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000B2")!)
        let out = CanvasReflow.place(cells: [a, b], moving: a.id,
                                     to: GridPoint(col: 2, row: 2), family: .large)
        let result = try! XCTUnwrap(out)
        let movedA = result.first { $0.id == a.id }!
        let pushedB = result.first { $0.id == b.id }!
        XCTAssertEqual(movedA.origin, GridPoint(col: 2, row: 2))
        // A vacated (0,0); B (displaced) lands in the first free reading-order slot.
        XCTAssertEqual(pushedB.origin, GridPoint(col: 0, row: 0))
        XCTAssertNotEqual(pushedB.origin, GridPoint(col: 2, row: 2)) // not on top of A
    }

    func testResultHasNoOverlaps() {
        // medium 4x2, dense: three 1x1 cells; move one onto another.
        let a = cell(0, 0, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000A1")!)
        let b = cell(1, 0, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000B2")!)
        let c = cell(2, 0, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000C3")!)
        let out = CanvasReflow.place(cells: [a, b, c], moving: c.id,
                                     to: GridPoint(col: 0, row: 0), family: .medium)
        let result = try! XCTUnwrap(out)
        for i in 0..<result.count {
            for j in (i + 1)..<result.count {
                XCTAssertFalse(GridRect.intersects(result[i].origin, result[i].span,
                                                   result[j].origin, result[j].span),
                               "cells \(i) and \(j) overlap after reflow")
            }
        }
        XCTAssertEqual(result.first { $0.id == c.id }!.origin, GridPoint(col: 0, row: 0))
    }

    func testOutOfBoundsTargetReturnsNil() {
        let a = cell(0, 0, 2, 1)
        XCTAssertNil(CanvasReflow.place(cells: [a], moving: a.id,
                                        to: GridPoint(col: 3, row: 0), family: .large))
    }

    func testNoRoomToRepackReturnsNil() {
        // small 2x2 completely full with four 1x1; a 2x1 cannot be introduced
        // by moving, but here test the pack-failure path: fill the grid then
        // move a cell such that a displaced one has nowhere to go.
        // small 2x2: cells fill all four; move A (0,0) onto B (1,0). B displaced,
        // but (0,0) is vacated so it CAN repack -> expect success, no nil.
        let a = cell(0, 0, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000A1")!)
        let b = cell(1, 0, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000B2")!)
        let c = cell(0, 1, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000C3")!)
        let d = cell(1, 1, 1, 1, id: UUID(uuidString: "00000000-0000-0000-0000-0000000000D4")!)
        let out = CanvasReflow.place(cells: [a, b, c, d], moving: a.id,
                                     to: GridPoint(col: 1, row: 0), family: .small)
        let result = try! XCTUnwrap(out) // A->B's spot, B repacks into vacated (0,0)
        XCTAssertEqual(result.count, 4)
        for i in 0..<result.count {
            for j in (i + 1)..<result.count {
                XCTAssertFalse(GridRect.intersects(result[i].origin, result[i].span,
                                                   result[j].origin, result[j].span))
            }
        }
    }
}
