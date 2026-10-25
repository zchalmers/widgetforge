import XCTest
@testable import WidgetForgeKit

final class ManifestStoreTests: XCTestCase {
    private func makeContainer() throws -> SharedContainer {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        return SharedContainer(overrideURL: tmp)
    }

    private func sampleManifest(_ bundleId: String) -> AppCapabilityManifest {
        AppCapabilityManifest(
            bundleId: bundleId, displayName: bundleId, accentHex: "#FFFFFF",
            iconAssetName: nil, deepLinkScheme: "x",
            slices: [DataSlice(id: "s", displayName: "Slice", kind: .count,
                               value: .count(1), deepLink: nil,
                               refreshedAt: Date(timeIntervalSince1970: 1))],
            refreshedAt: Date(timeIntervalSince1970: 1)
        )
    }

    func testRoundTrip() throws {
        let store = ManifestStore(container: try makeContainer())
        let m = sampleManifest("com.example.Dashboard")
        try store.write(m)
        XCTAssertEqual(store.read(bundleId: "com.example.Dashboard"), m)
    }

    func testMultiWriterIsolation() throws {
        let store = ManifestStore(container: try makeContainer())
        try store.write(sampleManifest("com.example.Dashboard"))
        try store.write(sampleManifest("com.example.DealApproval"))
        let all = store.readAll().map(\.bundleId).sorted()
        XCTAssertEqual(all, ["com.example.DealApproval", "com.example.Dashboard"])
    }

    func testSchemaTooNewIsSkipped() throws {
        let c = try makeContainer()
        let store = ManifestStore(container: c)
        let m = sampleManifest("com.example.Dashboard")
        try store.write(m)
        // Rewrite the file with a higher schema version.
        var mutable = try JSONSerialization.jsonObject(with: Data(contentsOf: c.manifestURL(for: "com.example.Dashboard")!)) as! [String: Any]
        mutable["schemaVersion"] = 99
        let data = try JSONSerialization.data(withJSONObject: mutable, options: [.sortedKeys])
        try data.write(to: c.manifestURL(for: "com.example.Dashboard")!)
        XCTAssertEqual(store.readAll().count, 0)
    }

    func testDecodeFailedIsSkippedInReadAll() throws {
        let c = try makeContainer()
        try FileManager.default.createDirectory(at: c.manifestsDirectoryURL()!, withIntermediateDirectories: true)
        try "not json".data(using: .utf8)!.write(to: c.manifestURL(for: "com.example.Bogus")!)
        XCTAssertEqual(ManifestStore(container: c).readAll(), [])
    }

    func testRemove() throws {
        let store = ManifestStore(container: try makeContainer())
        try store.write(sampleManifest("com.example.Dashboard"))
        try store.remove(bundleId: "com.example.Dashboard")
        XCTAssertNil(store.read(bundleId: "com.example.Dashboard"))
    }

    func testRefreshedAt() throws {
        let store = ManifestStore(container: try makeContainer())
        let m = sampleManifest("com.example.Dashboard")
        try store.write(m)
        XCTAssertEqual(store.refreshedAt(bundleId: "com.example.Dashboard"), m.refreshedAt)
    }
}
