import XCTest
@testable import WidgetForgeKit

final class SharedContainerTests: XCTestCase {
    func testOverrideURLPaths() throws {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        let c = SharedContainer(overrideURL: tmp)
        XCTAssertEqual(c.manifestURL(for: "com.example.Dashboard")?.lastPathComponent, "com.example.Dashboard.json")
        XCTAssertEqual(c.manifestsDirectoryURL()?.lastPathComponent, "manifests")
        XCTAssertEqual(c.layoutsDirectoryURL()?.lastPathComponent, "layouts")
        XCTAssertEqual(c.layoutIndexURL()?.lastPathComponent, "index.json")
        let id = UUID()
        XCTAssertEqual(c.layoutURL(for: id)?.lastPathComponent, "\(id.uuidString).json")
    }

    func testDefaultAppGroupValue() {
        XCTAssertEqual(SharedContainer.defaultAppGroup, "group.com.example.widgetforge.shared")
    }
}
