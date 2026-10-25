import XCTest
@testable import WidgetForgeKit

final class WidgetIntentContextTests: XCTestCase {

    private var tmpDir: URL!
    private var store: ManifestStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("WFIntentsTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            at: tmpDir.appendingPathComponent("manifests"),
            withIntermediateDirectories: true)
        store = ManifestStore(container: SharedContainer(overrideURL: tmpDir))
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tmpDir)
        tmpDir = nil
        store = nil
        try super.tearDownWithError()
    }

    private func writeManifest(bundleId: String, slices: [DataSlice], displayName: String = "Inbox", scheme: String = "inbox") throws {
        let m = AppCapabilityManifest(
            bundleId: bundleId,
            displayName: displayName,
            accentHex: "#F9B71A",
            iconAssetName: nil,
            deepLinkScheme: scheme,
            slices: slices,
            refreshedAt: Date()
        )
        try store.write(m)
    }

    private func countSlice(_ id: String, _ n: Int) -> DataSlice {
        DataSlice(id: id, displayName: "Pending Approvals", kind: .count,
                  value: .count(n), deepLink: nil, refreshedAt: Date())
    }

    private func listSlice() -> DataSlice {
        DataSlice(id: "topApprovals", displayName: "Top Approvals", kind: .list,
                  value: .list([
                    .init(id: "1", title: "Alpha"),
                    .init(id: "2", title: "Beta"),
                    .init(id: "3", title: "Gamma"),
                    .init(id: "4", title: "Delta")
                  ]), deepLink: nil, refreshedAt: Date())
    }

    func test_snapshot_countKind_returnsSpokenDialog() throws {
        try writeManifest(bundleId: "com.example.it.inbox", slices: [countSlice("pendingCount", 7)])
        let snap = WidgetIntentContext.snapshot(for: "com.example.it.inbox",
                                             kind: .count,
                                             store: store)
        let unwrapped = try XCTUnwrap(snap)
        XCTAssertEqual(unwrapped.sliceId, "pendingCount")
        XCTAssertEqual(WidgetIntentContext.spokenDialog(for: unwrapped),
                       "You have 7 pending in Inbox.")
    }

    func test_snapshot_listKind_speaksTopThree() throws {
        try writeManifest(bundleId: "com.example.it.inbox", slices: [listSlice()])
        let snap = try XCTUnwrap(WidgetIntentContext.snapshot(
            for: "com.example.it.inbox", kind: .list, store: store))
        XCTAssertEqual(WidgetIntentContext.spokenDialog(for: snap),
                       "Top 3 in Inbox: Alpha, Beta, Gamma.")
    }

    func test_snapshot_missingManifest_returnsNil() {
        let snap = WidgetIntentContext.snapshot(for: "com.example.unknown",
                                             kind: .count,
                                             store: store)
        XCTAssertNil(snap)
    }

    func test_appSuggestions_unionsManifestAndCatalog() throws {
        // Only Dashboard has a live manifest; the rest are catalog-only.
        try writeManifest(bundleId: "com.example.Dashboard",
                          slices: [countSlice("actionRequiredCount", 2)],
                          displayName: "Pipeline",
                          scheme: "pipeline")
        let suggestions = WidgetIntentContext.appSuggestions(store: store)
        let ids = Set(suggestions.map { $0.entry.bundleId })
        XCTAssertTrue(ids.contains("com.example.Dashboard"))
        XCTAssertTrue(ids.contains("com.example.it.inbox"))
        // Wellness is catalog-only (no live manifest) but now has catalog
        // entries, so it must still surface via the catalog union.
        XCTAssertTrue(ids.contains("com.example.example.fitwidget"))
    }

    func test_sliceSuggestions_prefersLiveOverCatalog() throws {
        try writeManifest(bundleId: "com.example.it.inbox",
                          slices: [countSlice("pendingCount", 3)])
        let all = WidgetIntentContext.sliceSuggestions(store: store)
        let approveIT = all.filter { $0.entry.bundleId == "com.example.it.inbox" }
        // pendingCount exists in both live + catalog; must appear exactly once as live.
        let pendings = approveIT.filter { $0.sliceId == "pendingCount" }
        XCTAssertEqual(pendings.count, 1)
        XCTAssertTrue(pendings.first?.hasManifest ?? false)
    }

    func test_manifestsDigest_empty_returnsSentinel() {
        XCTAssertEqual(WidgetIntentContext.manifestsDigest(store: store),
                       "No Widget apps are publishing data yet.")
    }

    func test_manifestsDigest_containsCountAndSliceName() throws {
        try writeManifest(bundleId: "com.example.it.inbox",
                          slices: [countSlice("pendingCount", 5)])
        let digest = WidgetIntentContext.manifestsDigest(store: store)
        XCTAssertTrue(digest.contains("Pending Approvals=5"), digest)
    }

    func test_openURL_forEntry_usesScheme() {
        let entry = AppRegistry.default.entry(for: "com.example.it.inbox")!
        XCTAssertEqual(WidgetIntentContext.openURL(for: entry),
                       URL(string: "inbox://")!)
    }

    func test_knownSliceCatalog_hasInboxEntries() {
        let slices = KnownSliceCatalog.slices(for: "com.example.it.inbox")
        XCTAssertEqual(slices.count, 3)
        XCTAssertTrue(slices.contains(where: { $0.sliceId == "pendingCount" && $0.kind == .count }))
    }
}
