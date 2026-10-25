import XCTest
@testable import WidgetForgeKit
import CoreGraphics

final class GridGeometryTests: XCTestCase {
    // medium = 4 cols x 2 rows; 360x160 => cell 90x80.
    private let geo = GridGeometry(family: .medium, size: CGSize(width: 360, height: 160))

    func testCellDimensions() {
        XCTAssertEqual(geo.cellWidth, 90, accuracy: 0.001)
        XCTAssertEqual(geo.cellHeight, 80, accuracy: 0.001)
    }

    func testSnappedOriginRoundsToNearestCell() {
        // Offset of ~1.4 cells right, ~0.6 cells down => col 1, row 1.
        let p = geo.snappedOrigin(pixelOffset: CGSize(width: 130, height: 50), span: GridSize(cols: 1, rows: 1))
        XCTAssertEqual(p, GridPoint(col: 1, row: 1))
    }

    func testSnappedOriginClampsWithinBoundsForSpan() {
        // A 2x1 cell dragged far right cannot start past col 2 (2+2 <= 4).
        let p = geo.snappedOrigin(pixelOffset: CGSize(width: 999, height: 999), span: GridSize(cols: 2, rows: 1))
        XCTAssertEqual(p, GridPoint(col: 2, row: 1))
    }

    func testSnappedOriginClampsNegative() {
        let p = geo.snappedOrigin(pixelOffset: CGSize(width: -999, height: -999), span: GridSize(cols: 1, rows: 1))
        XCTAssertEqual(p, GridPoint(col: 0, row: 0))
    }

    func testSpanDeltaRoundsTranslation() {
        // +100px wide (~1.1 cells), -30px tall (~-0.4 cells) => (+1, 0).
        let d = geo.spanDelta(pixelTranslation: CGSize(width: 100, height: -30))
        XCTAssertEqual(d.dCols, 1)
        XCTAssertEqual(d.dRows, 0)
    }

    func testPixelFrameRoundTrip() {
        let rect = geo.pixelFrame(origin: GridPoint(col: 1, row: 0), span: GridSize(cols: 2, rows: 1))
        XCTAssertEqual(rect, CGRect(x: 90, y: 0, width: 180, height: 80))
    }
}
