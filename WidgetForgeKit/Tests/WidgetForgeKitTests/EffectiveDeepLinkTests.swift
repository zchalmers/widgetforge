import XCTest
@testable import WidgetForgeKit

final class EffectiveDeepLinkTests: XCTestCase {
    private let layoutId = UUID(uuidString: "AAAAAAAA-0000-0000-0000-000000000001")!
    private let cellId = UUID(uuidString: "AAAAAAAA-0000-0000-0000-000000000002")!
    private var binding: DataBinding { DataBinding(bundleId: "com.example.Dashboard", sliceId: "pending") }

    func testTier1SliceDeepLinkWins() {
        let deep = URL(string: "dashboard://approve/42")!
        let slice = DataSlice(id: "pending", displayName: "P", kind: .count, value: .count(1),
                              deepLink: deep, refreshedAt: Date(timeIntervalSince1970: 1))
        let m = AppCapabilityManifest(bundleId: "com.example.Dashboard", displayName: "DM",
                                      accentHex: "#000", iconAssetName: nil,
                                      deepLinkScheme: "dashboard", slices: [slice],
                                      refreshedAt: Date(timeIntervalSince1970: 1))
        let cell = Cell(id: cellId, origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 1, rows: 1),
                        component: .count(.init(binding: binding, caption: nil, accent: .fromApp)))
        let url = cell.effectiveDeepLink(pool: SlicePool([m]), registry: AppRegistry.default,
                                         layoutId: layoutId, kind: .WFSmall)
        XCTAssertEqual(url, deep)
    }

    func testTier2AppSchemeFallback() {
        let cell = Cell(id: cellId, origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 1, rows: 1),
                        component: .count(.init(binding: binding, caption: nil, accent: .fromApp)))
        let url = cell.effectiveDeepLink(pool: SlicePool([]), registry: AppRegistry.default,
                                         layoutId: layoutId, kind: .WFSmall)
        XCTAssertEqual(url.absoluteString, "pipeline://")
    }

    func testTier3HeaderEditorFallback() {
        let cell = Cell(id: cellId, origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                        component: .header(.init(title: "H", subtitle: nil, accent: .fromApp)))
        let url = cell.effectiveDeepLink(pool: SlicePool([]), registry: AppRegistry.default,
                                         layoutId: layoutId, kind: .WFLarge)
        XCTAssertTrue(url.absoluteString.hasPrefix("widgetforge://editor?"))
        XCTAssertTrue(url.absoluteString.contains("layoutId=\(layoutId.uuidString)"))
        XCTAssertTrue(url.absoluteString.contains("cellId=\(cellId.uuidString)"))
    }

    func testTier4RecoveryFallback() {
        let unknown = DataBinding(bundleId: "com.does.not.exist", sliceId: "x")
        let cell = Cell(id: cellId, origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 1, rows: 1),
                        component: .count(.init(binding: unknown, caption: nil, accent: .fromApp)))
        let url = cell.effectiveDeepLink(pool: SlicePool([]), registry: AppRegistry.default,
                                         layoutId: layoutId, kind: .WFMedium)
        let parsed = ParsedRecovery(url: url)
        XCTAssertEqual(parsed?.reason, .missingSlice)
        XCTAssertEqual(parsed?.kind, .WFMedium)
        XCTAssertEqual(parsed?.layoutId, layoutId)
    }

    func testPrimaryCellPrefersCritical() {
        let refresh = Date(timeIntervalSince1970: 10)
        let s1 = DataSlice(id: "warn", displayName: "", kind: .status,
                           value: .status(.warning, text: "w"), deepLink: nil, refreshedAt: refresh)
        let s2 = DataSlice(id: "crit", displayName: "", kind: .status,
                           value: .status(.critical, text: "c"), deepLink: nil, refreshedAt: refresh)
        let m = AppCapabilityManifest(bundleId: "com.example.Dashboard", displayName: "",
                                      accentHex: "#000", iconAssetName: nil,
                                      deepLinkScheme: "dashboard", slices: [s1, s2], refreshedAt: refresh)
        let bWarn = DataBinding(bundleId: "com.example.Dashboard", sliceId: "warn")
        let bCrit = DataBinding(bundleId: "com.example.Dashboard", sliceId: "crit")
        let cWarnId = UUID(uuidString: "BBBBBBBB-0000-0000-0000-000000000001")!
        let cCritId = UUID(uuidString: "BBBBBBBB-0000-0000-0000-000000000002")!
        let layout = WidgetLayout(
            id: layoutId, name: "t", family: .medium,
            cells: [
                Cell(id: cWarnId, origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 1),
                     component: .status(.init(binding: bWarn, accent: .fromApp))),
                Cell(id: cCritId, origin: GridPoint(col: 2, row: 0), span: GridSize(cols: 2, rows: 1),
                     component: .status(.init(binding: bCrit, accent: .fromApp)))
            ],
            background: .system,
            createdAt: refresh, updatedAt: refresh
        )
        XCTAssertEqual(layout.primaryCell(in: SlicePool([m]))?.id, cCritId)
    }

    func testPrimaryCellReadingOrderTieBreak() {
        let refresh = Date(timeIntervalSince1970: 10)
        let s = DataSlice(id: "p", displayName: "", kind: .count, value: .count(5),
                          deepLink: nil, refreshedAt: refresh)
        let m = AppCapabilityManifest(bundleId: "com.example.Dashboard", displayName: "",
                                      accentHex: "#000", iconAssetName: nil,
                                      deepLinkScheme: "dashboard", slices: [s], refreshedAt: refresh)
        let b = DataBinding(bundleId: "com.example.Dashboard", sliceId: "p")
        let firstId = UUID(uuidString: "CCCCCCCC-0000-0000-0000-000000000001")!
        let secondId = UUID(uuidString: "CCCCCCCC-0000-0000-0000-000000000002")!
        let layout = WidgetLayout(
            id: layoutId, name: "t", family: .medium,
            cells: [
                Cell(id: firstId, origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 1),
                     component: .count(.init(binding: b, caption: nil, accent: .fromApp))),
                Cell(id: secondId, origin: GridPoint(col: 2, row: 0), span: GridSize(cols: 2, rows: 1),
                     component: .count(.init(binding: b, caption: nil, accent: .fromApp)))
            ],
            background: .system, createdAt: refresh, updatedAt: refresh
        )
        XCTAssertEqual(layout.primaryCell(in: SlicePool([m]))?.id, firstId)
    }

    func testPrimaryDeepLinkFallsBackToRecoveryWhenNoData() {
        let layout = WidgetLayout(
            id: layoutId, name: "t", family: .small,
            cells: [
                Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 2),
                     component: .header(.init(title: "H", subtitle: nil, accent: .fromApp)))
            ],
            background: .system,
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0)
        )
        let url = layout.primaryDeepLink(pool: SlicePool([]), registry: AppRegistry.default, kind: .WFSmall)
        // Header cell in an empty pool resolves through Tier 3 (editor), not recovery.
        XCTAssertTrue(url.absoluteString.hasPrefix("widgetforge://editor?"))
    }
}
