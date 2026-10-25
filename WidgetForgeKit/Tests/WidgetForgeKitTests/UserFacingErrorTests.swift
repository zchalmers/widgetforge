import XCTest
@testable import WidgetForgeKit

final class UserFacingErrorTests: XCTestCase {
    func testAllCasesHaveNonEmptyCopy() {
        let cases: [WidgetForgeError] = [
            .containerUnavailable,
            .coordinationFailed(underlying: NSError(domain: "x", code: 1)),
            .decodeFailed(fileName: "com.example.Dashboard.json", underlying: NSError(domain: "x", code: 2)),
            .schemaTooNew(fileName: "com.example.Dashboard.json", version: 9),
            .cellOverlap(a: UUID(), b: UUID()),
            .cellOutOfBounds(cell: UUID(), family: .large),
            .invalidBinding(reason: "kind mismatch")
        ]
        for c in cases {
            XCTAssertFalse(c.userTitle.isEmpty, "empty title: \(c)")
            XCTAssertFalse(c.userExplanation.isEmpty, "empty explanation: \(c)")
            XCTAssertFalse(c.userTitle.contains("—"), "em dash in title: \(c)")
            XCTAssertFalse(c.userExplanation.contains("—"), "em dash in explanation: \(c)")
        }
    }

    func testRetryActionMapping() {
        XCTAssertEqual(WidgetForgeError.containerUnavailable.userRetryAction, .openAppsTab)
        XCTAssertEqual(WidgetForgeError.coordinationFailed(underlying: NSError(domain: "x", code: 0)).userRetryAction, .reload)
        XCTAssertEqual(WidgetForgeError.decodeFailed(fileName: "a", underlying: NSError(domain: "x", code: 0)).userRetryAction, .reload)
        XCTAssertEqual(WidgetForgeError.schemaTooNew(fileName: "a", version: 2).userRetryAction, .openAppsTab)
        let id = UUID()
        XCTAssertEqual(WidgetForgeError.cellOverlap(a: id, b: UUID()).userRetryAction, nil)
        XCTAssertEqual(WidgetForgeError.cellOutOfBounds(cell: id, family: .small).userRetryAction, nil)
        XCTAssertEqual(WidgetForgeError.invalidBinding(reason: "r").userRetryAction, .openAppsTab)
    }
}
