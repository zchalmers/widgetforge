import XCTest
@testable import WidgetForgeKit

final class LayoutAuthorTests: XCTestCase {
    func testSeedDefaultProducesValidLayoutForEveryFamily() throws {
        for family in LayoutFamily.allCases {
            let layout = LayoutAuthor.seedDefault(family: family)
            XCTAssertEqual(layout.family, family)
            XCTAssertFalse(layout.cells.isEmpty)
            // Must pass the same validation LayoutStore.write enforces.
            XCTAssertNoThrow(try LayoutValidator.validate(layout))
        }
    }

    func testAvailabilityReturnsAKnownCase() {
        // Just exercises the branch logic without needing a model on the host.
        let a = LayoutAuthor.availability()
        XCTAssertTrue([.available, .unavailable, .unsupported].contains(a))
    }
}
