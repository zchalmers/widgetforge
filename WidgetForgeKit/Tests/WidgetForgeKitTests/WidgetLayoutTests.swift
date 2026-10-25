import XCTest
@testable import WidgetForgeKit

final class WidgetLayoutTests: XCTestCase {
    func testRoundTrip() throws {
        let l = WidgetLayout(
            id: UUID(),
            name: "Sales day",
            family: .medium,
            cells: [
                Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 1),
                     component: .header(.init(title: "Today", subtitle: nil, accent: .fromApp)))
            ],
            background: .system,
            createdAt: Date(timeIntervalSince1970: 1),
            updatedAt: Date(timeIntervalSince1970: 2)
        )
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        XCTAssertEqual(try dec.decode(WidgetLayout.self, from: try enc.encode(l)), l)
    }
}
