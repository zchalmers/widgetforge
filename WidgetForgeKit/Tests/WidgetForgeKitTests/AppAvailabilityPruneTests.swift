import XCTest
@testable import WidgetForgeKit

final class AppAvailabilityPruneTests: XCTestCase {
    private func makeContainer() throws -> SharedContainer {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        return SharedContainer(overrideURL: tmp)
    }

    private func makeManifest(bundleId: String) -> AppCapabilityManifest {
        AppCapabilityManifest(
            bundleId: bundleId,
            displayName: bundleId,
            accentHex: "#FFFFFF",
            iconAssetName: nil,
            deepLinkScheme: "x",
            slices: [
                DataSlice(id: "s", displayName: "S", kind: .count,
                          value: .count(1), deepLink: nil,
                          refreshedAt: Date(timeIntervalSince1970: 1))
            ],
            refreshedAt: Date(timeIntervalSince1970: 1)
        )
    }

    private func makeEntry(bundleId: String) -> AppRegistry.Entry {
        AppRegistry.Entry(bundleId: bundleId, displayName: bundleId,
                          scheme: "x", accentHex: "#000000",
                          iconAssetName: nil, confirmed: true)
    }

    func testRemovesManifestForNotInstalledEntry() throws {
        let container = try makeContainer()
        let store = ManifestStore(container: container)
        let bundleId = "com.example.notinstalled"
        try store.write(makeManifest(bundleId: bundleId))
        XCTAssertNotNil(store.read(bundleId: bundleId))

        let results: [AppAvailability.Result] = [
            AppAvailability.Result(entry: makeEntry(bundleId: bundleId),
                                   status: .notInstalled)
        ]
        let removed = AppAvailability.pruneUninstalled(results: results, store: store)
        XCTAssertEqual(removed, 1)
        XCTAssertNil(store.read(bundleId: bundleId))
    }

    func testSkipsWhenManifestAbsent() throws {
        let container = try makeContainer()
        let store = ManifestStore(container: container)
        let results: [AppAvailability.Result] = [
            AppAvailability.Result(entry: makeEntry(bundleId: "com.example.never"),
                                   status: .notInstalled)
        ]
        // No manifest on disk: prune must be a silent no-op and not throw.
        let removed = AppAvailability.pruneUninstalled(results: results, store: store)
        XCTAssertEqual(removed, 0)
    }

    func testDoesNotRemoveManifestForReadyEntry() throws {
        let container = try makeContainer()
        let store = ManifestStore(container: container)
        let bundleId = "com.example.ready"
        try store.write(makeManifest(bundleId: bundleId))

        let results: [AppAvailability.Result] = [
            AppAvailability.Result(entry: makeEntry(bundleId: bundleId), status: .ready),
            AppAvailability.Result(entry: makeEntry(bundleId: "com.example.stale"),
                                   status: .stale(publishedAt: Date(timeIntervalSince1970: 1))),
            AppAvailability.Result(entry: makeEntry(bundleId: "com.example.pub"),
                                   status: .installedNotPublishing)
        ]
        let removed = AppAvailability.pruneUninstalled(results: results, store: store)
        XCTAssertEqual(removed, 0)
        XCTAssertNotNil(store.read(bundleId: bundleId))
    }
}
