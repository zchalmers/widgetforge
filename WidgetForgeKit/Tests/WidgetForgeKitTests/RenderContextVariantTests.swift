import XCTest
@testable import WidgetForgeKit

final class RenderContextVariantTests: XCTestCase {
    private func manifest(_ bundleId: String, sliceId: String = "pendingCount", count: Int = 7) -> AppCapabilityManifest {
        AppCapabilityManifest(
            bundleId: bundleId, displayName: "Wellness", accentHex: "#4ACF6B",
            iconAssetName: "fitwidget", deepLinkScheme: "fitwidget",
            slices: [DataSlice(id: sliceId, displayName: "S", kind: .count, value: .count(count), deepLink: nil, refreshedAt: Date(timeIntervalSince1970: 0))],
            refreshedAt: Date(timeIntervalSince1970: 0))
    }

    func testExactBundleIdResolves() {
        let ctx = RenderContext(pool: SlicePool([manifest("com.example.example.fitwidget")]), registry: .default)
        let slice = ctx.slice(for: DataBinding(bundleId: "com.example.example.fitwidget", sliceId: "pendingCount"))
        XCTAssertEqual(slice?.value, .count(7))
    }

    func testInternalVariantResolvesForProdBinding() {
        // Layout binds prod id; only an installed .internal build has published.
        let ctx = RenderContext(pool: SlicePool([manifest("com.example.example.fitwidget.internal")]), registry: .default)
        let slice = ctx.slice(for: DataBinding(bundleId: "com.example.example.fitwidget", sliceId: "pendingCount"))
        XCTAssertEqual(slice?.value, .count(7), "prod binding should resolve an installed internal variant of the same app")
    }

    func testUnrelatedBundleDoesNotResolve() {
        // A Pipeline manifest must not satisfy a Wellness binding.
        let dm = AppCapabilityManifest(
            bundleId: "com.example.Dashboard", displayName: "Pipeline", accentHex: "#3ECCB8",
            iconAssetName: "dashboard", deepLinkScheme: "pipeline",
            slices: [DataSlice(id: "pendingCount", displayName: "S", kind: .count, value: .count(3), deepLink: nil, refreshedAt: Date(timeIntervalSince1970: 0))],
            refreshedAt: Date(timeIntervalSince1970: 0))
        let ctx = RenderContext(pool: SlicePool([dm]), registry: .default)
        XCTAssertNil(ctx.slice(for: DataBinding(bundleId: "com.example.example.fitwidget", sliceId: "pendingCount")))
    }

    // MARK: - Deep link variant resolution

    /// A cell bound to the prod id should return the slice-level deepLink from an
    /// installed internal variant's manifest (not just fall back to the scheme).
    func testDeepLinkUsesVariantSliceURL() {
        let deep = URL(string: "fitwidget://item/42")!
        let m = AppCapabilityManifest(
            bundleId: "com.example.example.fitwidget.internal", displayName: "Wellness", accentHex: "#4ACF6B",
            iconAssetName: "fitwidget", deepLinkScheme: "fitwidget",
            slices: [DataSlice(id: "stepsToday", displayName: "Steps", kind: .metric,
                               value: .metric(8342, unit: "steps", trend: .up), deepLink: deep,
                               refreshedAt: Date(timeIntervalSince1970: 0))],
            refreshedAt: Date(timeIntervalSince1970: 0))
        let cell = Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 1),
                        component: .metric(MetricConfig(binding: DataBinding(bundleId: "com.example.example.fitwidget", sliceId: "stepsToday"), caption: "Steps", accent: .fromApp)))
        let url = cell.effectiveDeepLink(pool: SlicePool([m]), registry: .default,
                                         layoutId: UUID(), kind: .WFSmall)
        XCTAssertEqual(url, deep, "prod-bound cell should resolve the internal variant's slice deepLink")
    }
}
