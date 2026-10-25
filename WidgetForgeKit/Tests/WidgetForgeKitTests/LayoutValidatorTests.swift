import XCTest
@testable import WidgetForgeKit

final class LayoutValidatorTests: XCTestCase {
    private func layout(family: LayoutFamily, cells: [Cell]) -> WidgetLayout {
        WidgetLayout(name: "t", family: family, cells: cells, background: .system)
    }
    private func headerCell(_ origin: GridPoint, _ span: GridSize, id: UUID = UUID()) -> Cell {
        Cell(id: id, origin: origin, span: span,
             component: .header(.init(title: "H", subtitle: nil, accent: .fromApp)))
    }

    func testValidMediumPasses() throws {
        let l = layout(family: .medium, cells: [
            headerCell(GridPoint(col: 0, row: 0), GridSize(cols: 4, rows: 1)),
            headerCell(GridPoint(col: 0, row: 1), GridSize(cols: 2, rows: 1)),
            headerCell(GridPoint(col: 2, row: 1), GridSize(cols: 2, rows: 1))
        ])
        try LayoutValidator.validate(l)
    }

    func testOutOfBoundsSmall() {
        let cellId = UUID()
        let l = layout(family: .small, cells: [
            headerCell(GridPoint(col: 1, row: 1), GridSize(cols: 2, rows: 1), id: cellId)
        ])
        XCTAssertThrowsError(try LayoutValidator.validate(l)) { e in
            guard case .cellOutOfBounds(let id, let fam) = e as! WidgetForgeError else {
                return XCTFail("wrong error")
            }
            XCTAssertEqual(id, cellId); XCTAssertEqual(fam, .small)
        }
    }

    func testNegativeOriginOutOfBounds() {
        let cellId = UUID()
        let l = layout(family: .medium, cells: [
            headerCell(GridPoint(col: -1, row: 0), GridSize(cols: 1, rows: 1), id: cellId)
        ])
        XCTAssertThrowsError(try LayoutValidator.validate(l))
    }

    func testZeroOrNegativeSpanRejected() {
        let l = layout(family: .medium, cells: [
            headerCell(GridPoint(col: 0, row: 0), GridSize(cols: 0, rows: 1))
        ])
        XCTAssertThrowsError(try LayoutValidator.validate(l))
    }

    func testOverlap() {
        let a = UUID(), b = UUID()
        let l = layout(family: .large, cells: [
            headerCell(GridPoint(col: 0, row: 0), GridSize(cols: 2, rows: 2), id: a),
            headerCell(GridPoint(col: 1, row: 1), GridSize(cols: 2, rows: 2), id: b)
        ])
        XCTAssertThrowsError(try LayoutValidator.validate(l)) { e in
            guard case .cellOverlap(let x, let y) = e as! WidgetForgeError else {
                return XCTFail("wrong")
            }
            XCTAssertEqual(Set([x, y]), Set([a, b]))
        }
    }

    func testFamiliesGridSizes() {
        XCTAssertEqual(LayoutFamily.small.cols, 2); XCTAssertEqual(LayoutFamily.small.rows, 2)
        XCTAssertEqual(LayoutFamily.medium.cols, 4); XCTAssertEqual(LayoutFamily.medium.rows, 2)
        XCTAssertEqual(LayoutFamily.large.cols, 4); XCTAssertEqual(LayoutFamily.large.rows, 4)
        XCTAssertEqual(LayoutFamily.extraLarge.cols, 4); XCTAssertEqual(LayoutFamily.extraLarge.rows, 6)
        XCTAssertEqual(LayoutFamily.xlPortrait.cols, 4); XCTAssertEqual(LayoutFamily.xlPortrait.rows, 6)
    }
}
