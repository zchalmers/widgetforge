import XCTest
@testable import WidgetForgeKit

final class AppCapabilityManifestTests: XCTestCase {
    func testCurrentSchemaVersion() {
        XCTAssertEqual(AppCapabilityManifest.currentSchemaVersion, 1)
    }
    func testRoundTrip() throws {
        let m = AppCapabilityManifest(
            schemaVersion: 1,
            bundleId: "com.example.Dashboard",
            displayName: "Pipeline",
            accentHex: "#3ECCB8",
            iconAssetName: "dashboard",
            deepLinkScheme: "dashboard",
            slices: [
                DataSlice(id: "pending", displayName: "Pending", kind: .count,
                          value: .count(3), deepLink: URL(string: "dashboard://pending"),
                          refreshedAt: Date(timeIntervalSince1970: 1_700_000_000))
            ],
            refreshedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; e.outputFormatting = [.sortedKeys]
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601
        let data = try e.encode(m)
        XCTAssertEqual(try d.decode(AppCapabilityManifest.self, from: data), m)
    }
}
