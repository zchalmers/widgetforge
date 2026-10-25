import XCTest
@testable import WidgetForgeKit

final class RenderContextTests: XCTestCase {
    func testSliceLookup() {
        let slice = DataSlice(id: "pending", displayName: "Pending", kind: .count,
                              value: .count(4), deepLink: nil,
                              refreshedAt: Date(timeIntervalSince1970: 1))
        let m = AppCapabilityManifest(
            bundleId: "com.example.Dashboard", displayName: "Pipeline", accentHex: "#000",
            iconAssetName: nil, deepLinkScheme: "dashboard",
            slices: [slice], refreshedAt: Date(timeIntervalSince1970: 1))
        let pool = SlicePool([m])
        XCTAssertEqual(pool.slice(for: DataBinding(bundleId: "com.example.Dashboard", sliceId: "pending"))?.id, "pending")
        XCTAssertNil(pool.slice(for: DataBinding(bundleId: "com.example.Dashboard", sliceId: "missing")))
        XCTAssertNil(pool.slice(for: DataBinding(bundleId: "com.other", sliceId: "pending")))
    }
}
