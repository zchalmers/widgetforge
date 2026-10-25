import XCTest
@testable import WidgetForgeKit

final class RecoveryDeepLinkTests: XCTestCase {
    func testHomeAndAppsAndHealth() {
        XCTAssertEqual(DeepLinkBuilder.home().absoluteString, "widgetforge://home")
        XCTAssertEqual(DeepLinkBuilder.apps().absoluteString, "widgetforge://apps")
        XCTAssertEqual(DeepLinkBuilder.health().absoluteString, "widgetforge://health")
    }

    func testEditorWithLayout() {
        let id = UUID()
        let url = DeepLinkBuilder.editor(layoutId: id)
        XCTAssertTrue(url.absoluteString.hasPrefix("widgetforge://editor?"))
        XCTAssertTrue(url.absoluteString.contains("layoutId=\(id.uuidString)"))
    }

    func testEditorWithLayoutAndCell() {
        let id = UUID(), cell = UUID()
        let url = DeepLinkBuilder.editor(layoutId: id, cellId: cell)
        XCTAssertTrue(url.absoluteString.contains("layoutId=\(id.uuidString)"))
        XCTAssertTrue(url.absoluteString.contains("cellId=\(cell.uuidString)"))
    }

    func testAllRecoveryReasonsParse() {
        let layoutId = UUID()
        for kind in WidgetKind.allCases {
            for reason in RecoveryReason.allCases {
                let url = DeepLinkBuilder.recover(kind: kind, reason: reason, layoutId: layoutId)
                guard let parsed = ParsedRecovery(url: url) else {
                    return XCTFail("failed to parse \(url)")
                }
                XCTAssertEqual(parsed.kind, kind)
                XCTAssertEqual(parsed.reason, reason)
                XCTAssertEqual(parsed.layoutId, layoutId)
            }
        }
    }

    func testRecoveryWithoutLayoutId() {
        let url = DeepLinkBuilder.recover(kind: .WFSmall, reason: .noManifests, layoutId: nil)
        let parsed = ParsedRecovery(url: url)
        XCTAssertEqual(parsed?.layoutId, nil)
        XCTAssertEqual(parsed?.kind, .WFSmall)
        XCTAssertEqual(parsed?.reason, .noManifests)
    }
}
