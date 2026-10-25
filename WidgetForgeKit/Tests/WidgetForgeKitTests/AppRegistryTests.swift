import XCTest
@testable import WidgetForgeKit

final class AppRegistryTests: XCTestCase {
    func testDefaultContainsAllConfirmedEntries() {
        let reg = AppRegistry.default
        XCTAssertEqual(reg.entries.count, 15)
        XCTAssertTrue(reg.entries.allSatisfy { $0.confirmed })
    }

    func testKnownBundleIdsPresent() {
        let reg = AppRegistry.default
        XCTAssertNotNil(reg.entry(for: "com.example.it.inbox"))
        XCTAssertNotNil(reg.entry(for: "com.example.Dashboard"))
        XCTAssertNotNil(reg.entry(for: "com.example.DealApproval"))
        XCTAssertNotNil(reg.entry(for: "com.example.example.fitwidget"))
        XCTAssertNotNil(reg.entry(for: "com.example.Time Tracker.internal"))
        XCTAssertNotNil(reg.entry(for: "com.example.example.Milestones"))
        XCTAssertNotNil(reg.entry(for: "com.example.timeoff"))
    }

    func testEntryLookupReturnsNilForUnknown() {
        XCTAssertNil(AppRegistry.default.entry(for: "com.does.not.exist"))
    }

    func testQuerySchemesMatchEntriesInOrder() {
        let reg = AppRegistry.default
        XCTAssertEqual(reg.querySchemes, reg.entries.map(\.scheme))
    }
}
