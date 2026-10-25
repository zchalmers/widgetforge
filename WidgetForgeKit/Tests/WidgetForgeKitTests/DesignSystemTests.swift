#if canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import WidgetForgeKit

final class DesignSystemTests: XCTestCase {
    func testKnownAccentsPresent() {
        XCTAssertNotNil(DesignSystem.appAccents["com.example.it.inbox"])
        XCTAssertNotNil(DesignSystem.appAccents["com.example.Dashboard"])
        XCTAssertNotNil(DesignSystem.appAccents["com.example.DealApproval"])
    }
    func testAccentLookupFallsBackToDefault() {
        let a = DesignSystem.accent(for: "com.does.not.exist")
        XCTAssertEqual(a.symbol, DesignSystem.defaultAccent.symbol)
    }
    func testTokenOrderAndCoverage() {
        XCTAssertEqual(AccentChoice.Token.allCases, [.amber, .teal, .violet, .mint, .coral])
        for t in AccentChoice.Token.allCases { _ = DesignSystem.color(for: t) }
    }
    func testHexParsing() {
        _ = DesignSystem.color(fromHex: "#3ECCB8")
        _ = DesignSystem.color(fromHex: "3ECCB8")
    }
    func testChipStyleForEveryAvailabilityStatus() {
        let ready = DesignSystem.chipStyle(for: .ready)
        let publishing = DesignSystem.chipStyle(for: .installedNotPublishing)
        let notInstalled = DesignSystem.chipStyle(for: .notInstalled)
        let stale = DesignSystem.chipStyle(for: .stale(publishedAt: Date(timeIntervalSince1970: 0)))
        // Distinct symbols per status so the UI never renders identical chips.
        let symbols = Set([ready.symbol, publishing.symbol, notInstalled.symbol, stale.symbol])
        XCTAssertEqual(symbols.count, 4)
    }
}
#endif
