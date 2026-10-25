import XCTest
@testable import WidgetForgeKit

final class LayoutBlueprintMapperTests: XCTestCase {

    private func cell(_ col: Int, _ row: Int, _ cols: Int, _ rows: Int,
                      kind: String, bundleId: String = "com.example.it.inbox",
                      sliceId: String = "pendingCount", text: String? = nil) -> LayoutBlueprintMapper.CellInput {
        .init(col: col, row: row, cols: cols, rows: rows, kind: kind,
              bundleId: bundleId, sliceId: sliceId, text: text)
    }

    func test_build_simpleMediumLayout_validates() throws {
        let input = LayoutBlueprintMapper.LayoutBlueprintInput(
            name: "Approvals",
            family: .medium,
            cells: [
                cell(0, 0, 4, 1, kind: "header", text: "Approvals"),
                cell(0, 1, 2, 1, kind: "count", sliceId: "pendingCount"),
                cell(2, 1, 2, 1, kind: "status", sliceId: "approvalStatus")
            ])
        let layout = try LayoutBlueprintMapper.build(input)
        XCTAssertEqual(layout.family, .medium)
        XCTAssertEqual(layout.cells.count, 3)
        XCTAssertNoThrow(try LayoutValidator.validate(layout))
    }

    func test_build_clampsOversizedCellIntoGrid() throws {
        // A 6x6 cell requested on a small (2x2) grid must clamp to fit.
        let input = LayoutBlueprintMapper.LayoutBlueprintInput(
            name: "Big",
            family: .small,
            cells: [cell(5, 5, 6, 6, kind: "count")])
        let layout = try LayoutBlueprintMapper.build(input)
        let c = layout.cells[0]
        XCTAssertLessThanOrEqual(c.origin.col + c.span.cols, 2)
        XCTAssertLessThanOrEqual(c.origin.row + c.span.rows, 2)
        XCTAssertNoThrow(try LayoutValidator.validate(layout))
    }

    func test_build_relocatesOverlappingCell() throws {
        // Two 4x1 cells both requesting row 0 — second must relocate, not overlap.
        let input = LayoutBlueprintMapper.LayoutBlueprintInput(
            name: "Stack",
            family: .large,
            cells: [
                cell(0, 0, 4, 1, kind: "header", text: "A"),
                cell(0, 0, 4, 1, kind: "count")
            ])
        let layout = try LayoutBlueprintMapper.build(input)
        XCTAssertEqual(layout.cells.count, 2)
        XCTAssertNoThrow(try LayoutValidator.validate(layout))
    }

    func test_build_dropsUnknownKinds() throws {
        let input = LayoutBlueprintMapper.LayoutBlueprintInput(
            name: "Mixed",
            family: .medium,
            cells: [
                cell(0, 0, 2, 1, kind: "count"),
                cell(2, 0, 2, 1, kind: "banana")  // unknown → dropped
            ])
        let layout = try LayoutBlueprintMapper.build(input)
        XCTAssertEqual(layout.cells.count, 1)
    }

    func test_build_throwsWhenNothingMappable() {
        let input = LayoutBlueprintMapper.LayoutBlueprintInput(
            name: "Empty",
            family: .medium,
            cells: [cell(0, 0, 1, 1, kind: "nonsense")])
        XCTAssertThrowsError(try LayoutBlueprintMapper.build(input)) { err in
            XCTAssertEqual(err as? LayoutBlueprintMapper.MapError, .noMappableCells)
        }
    }

    func test_build_headerUsesTextAsTitle() throws {
        let input = LayoutBlueprintMapper.LayoutBlueprintInput(
            name: "H",
            family: .medium,
            cells: [cell(0, 0, 4, 1, kind: "header", text: "My Approvals")])
        let layout = try LayoutBlueprintMapper.build(input)
        guard case .header(let cfg) = layout.cells[0].component else {
            return XCTFail("expected header")
        }
        XCTAssertEqual(cfg.title, "My Approvals")
    }
}
