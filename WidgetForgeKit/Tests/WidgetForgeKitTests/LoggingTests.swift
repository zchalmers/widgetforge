import XCTest
@testable import WidgetForgeKit

final class LoggingTests: XCTestCase {
    func testSubsystem() {
        XCTAssertEqual(WFLog.subsystem, "com.example.widgetforge")
    }
}
