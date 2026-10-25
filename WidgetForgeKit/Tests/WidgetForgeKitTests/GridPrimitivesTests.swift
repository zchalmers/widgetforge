import XCTest
@testable import WidgetForgeKit

final class GridPrimitivesTests: XCTestCase {
    func testGridPointRoundTrip() throws {
        let p = GridPoint(col: 1, row: 2)
        let data = try JSONEncoder().encode(p)
        XCTAssertEqual(try JSONDecoder().decode(GridPoint.self, from: data), p)
    }
    func testGridSizeRoundTrip() throws {
        let s = GridSize(cols: 2, rows: 3)
        XCTAssertEqual(try JSONDecoder().decode(GridSize.self, from: try JSONEncoder().encode(s)), s)
    }
    func testDataBindingRoundTrip() throws {
        let b = DataBinding(bundleId: "com.example.Dashboard", sliceId: "pending")
        XCTAssertEqual(try JSONDecoder().decode(DataBinding.self, from: try JSONEncoder().encode(b)), b)
    }
    func testAccentChoiceRoundTrip() throws {
        for a in [AccentChoice.fromApp, .token(.amber), .token(.teal), .token(.violet), .token(.mint), .token(.coral)] {
            let d = try JSONEncoder().encode(a)
            XCTAssertEqual(try JSONDecoder().decode(AccentChoice.self, from: d), a)
        }
    }
    func testBackgroundStyleRoundTrip() throws {
        for b in [BackgroundStyle.system, .accentHex("#112233"), .clear] {
            let d = try JSONEncoder().encode(b)
            XCTAssertEqual(try JSONDecoder().decode(BackgroundStyle.self, from: d), b)
        }
    }
}
