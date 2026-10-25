#if canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import WidgetForgeKit

final class LevelOfDetailAdapterTests: XCTestCase {
    func testConstructs() {
        _ = LevelOfDetailReader { lod in
            Text(String(describing: lod))
        }.body
    }
    func testCasesAndEquality() {
        XCTAssertEqual(WFLevelOfDetail.allCases, [.simplified, .default])
        XCTAssertNotEqual(WFLevelOfDetail.simplified, WFLevelOfDetail.default)
    }
}
#endif
