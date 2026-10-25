#if canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import WidgetForgeKit

final class WidgetErrorViewTests: XCTestCase {
    func testConstructsAllReasons() {
        let layoutId = UUID(uuidString: "DDDDDDDD-0000-0000-0000-000000000001")!
        for reason in RecoveryReason.allCases {
            _ = WidgetErrorView(kind: .WFSmall, reason: reason, layoutId: layoutId).body
        }
    }

    func testRecoveryURLRoundTripsAllReasons() {
        let layoutId = UUID(uuidString: "DDDDDDDD-0000-0000-0000-000000000002")!
        for kind in WidgetKind.allCases {
            for reason in RecoveryReason.allCases {
                let v = WidgetErrorView(kind: kind, reason: reason, layoutId: layoutId)
                guard let parsed = ParsedRecovery(url: v.recoveryURL) else {
                    return XCTFail("failed to parse \(v.recoveryURL)")
                }
                XCTAssertEqual(parsed.kind, kind)
                XCTAssertEqual(parsed.reason, reason)
                XCTAssertEqual(parsed.layoutId, layoutId)
            }
        }
    }

    func testRecoveryURLWithoutLayoutId() {
        let v = WidgetErrorView(kind: .WFLarge, reason: .noManifests, layoutId: nil)
        XCTAssertEqual(ParsedRecovery(url: v.recoveryURL)?.layoutId, nil)
    }
}
#endif
