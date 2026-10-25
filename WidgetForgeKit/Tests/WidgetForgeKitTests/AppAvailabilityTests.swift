import XCTest
@testable import WidgetForgeKit

final class AppAvailabilityTests: XCTestCase {
    private struct StubProbe: URLSchemeProbe {
        let installed: Set<String>
        func canOpen(scheme: String) -> Bool { installed.contains(scheme) }
    }
    private func makeContainer() throws -> SharedContainer {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        return SharedContainer(overrideURL: tmp)
    }

    func testReadyWhenInstalledAndFreshManifest() throws {
        let c = try makeContainer()
        let store = ManifestStore(container: c)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        try store.write(AppCapabilityManifest(
            bundleId: "com.example.Dashboard", displayName: "Pipeline", accentHex: "#000000",
            iconAssetName: nil, deepLinkScheme: "dashboard",
            slices: [], refreshedAt: now))
        let a = AppAvailability(
            registry: AppRegistry.default,
            manifests: store,
            probe: StubProbe(installed: ["pipeline"]),
            now: { now }
        )
        let s = a.status(for: AppRegistry.default.entry(for: "com.example.Dashboard")!)
        XCTAssertEqual(s, .ready)
    }

    func testInstalledButNotPublishing() throws {
        let c = try makeContainer()
        let a = AppAvailability(
            registry: AppRegistry.default,
            manifests: ManifestStore(container: c),
            probe: StubProbe(installed: ["pipeline"]),
            now: { Date(timeIntervalSince1970: 1) }
        )
        XCTAssertEqual(a.status(for: AppRegistry.default.entry(for: "com.example.Dashboard")!), .installedNotPublishing)
    }

    func testNotInstalled() throws {
        let c = try makeContainer()
        let a = AppAvailability(
            registry: AppRegistry.default,
            manifests: ManifestStore(container: c),
            probe: StubProbe(installed: []),
            now: { Date(timeIntervalSince1970: 1) }
        )
        XCTAssertEqual(a.status(for: AppRegistry.default.entry(for: "com.example.Dashboard")!), .notInstalled)
    }

    func testStaleManifest() throws {
        let c = try makeContainer()
        let store = ManifestStore(container: c)
        let published = Date(timeIntervalSince1970: 1_000_000)
        let now = published.addingTimeInterval(60 * 60 * 24 * 8) // 8 days
        try store.write(AppCapabilityManifest(
            bundleId: "com.example.Dashboard", displayName: "Pipeline", accentHex: "#000",
            iconAssetName: nil, deepLinkScheme: "dashboard",
            slices: [], refreshedAt: published))
        let a = AppAvailability(
            registry: AppRegistry.default,
            manifests: store,
            probe: StubProbe(installed: ["pipeline"]),
            now: { now }
        )
        XCTAssertEqual(a.status(for: AppRegistry.default.entry(for: "com.example.Dashboard")!), .stale(publishedAt: published))
    }

    func testUnconfirmedEntryReportsNotInstalled() throws {
        let entry = AppRegistry.Entry(bundleId: "com.example.pending", displayName: "Pending",
                                      scheme: "", accentHex: "#000", iconAssetName: nil,
                                      confirmed: false)
        let reg = AppRegistry(entries: [entry])
        let a = AppAvailability(
            registry: reg,
            manifests: ManifestStore(container: try makeContainer()),
            probe: StubProbe(installed: ["anything"]),
            now: { Date() }
        )
        XCTAssertEqual(a.status(for: entry), .notInstalled)
    }

    func testResultsCountsMatchRegistry() throws {
        let a = AppAvailability(
            registry: AppRegistry.default,
            manifests: ManifestStore(container: try makeContainer()),
            probe: StubProbe(installed: []),
            now: { Date() }
        )
        XCTAssertEqual(a.results().count, AppRegistry.default.entries.count)
    }
}
