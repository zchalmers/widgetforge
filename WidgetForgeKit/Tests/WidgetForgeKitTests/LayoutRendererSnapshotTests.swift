#if canImport(SwiftUI) && os(macOS)
import XCTest
import SwiftUI
import SnapshotTesting
import AppKit
@testable import WidgetForgeKit

final class LayoutRendererSnapshotTests: XCTestCase {
    @MainActor
    private func snapshot<V: View>(_ view: V, size: CGSize, record: Bool = false,
                                    file: StaticString = #file, testName: String = #function, line: UInt = #line) {
        let host = NSHostingView(rootView: view)
        host.frame = CGRect(origin: .zero, size: size)
        assertSnapshot(of: host, as: .image, record: record, file: file, testName: testName, line: line)
    }

    @MainActor
    private func render(_ layout: WidgetLayout, size: CGSize) -> some View {
        LayoutRenderer(
            layout: layout,
            context: RenderContext(pool: SlicePool([sampleManifest]), registry: AppRegistry.default)
        )
    }

    private var sampleManifest: AppCapabilityManifest {
        AppCapabilityManifest(
            schemaVersion: 1,
            bundleId: "com.example.Dashboard", displayName: "Pipeline",
            accentHex: "#3ECCB8", iconAssetName: "dashboard",
            deepLinkScheme: "dashboard",
            slices: [
                DataSlice(id: "pending", displayName: "Pending", kind: .count,
                          value: .count(4), deepLink: nil,
                          refreshedAt: Date(timeIntervalSince1970: 1)),
                DataSlice(id: "revenue", displayName: "Revenue", kind: .metric,
                          value: .metric(12.4, unit: "M", trend: .up),
                          deepLink: nil, refreshedAt: Date(timeIntervalSince1970: 1)),
                DataSlice(id: "health", displayName: "Health", kind: .status,
                          value: .status(.warning, text: "Backlog high"),
                          deepLink: nil, refreshedAt: Date(timeIntervalSince1970: 1)),
                DataSlice(id: "quota", displayName: "Quota", kind: .progress,
                          value: .progress(0.6, label: "Q3 quota"),
                          deepLink: nil, refreshedAt: Date(timeIntervalSince1970: 1)),
                DataSlice(id: "items", displayName: "Items", kind: .list,
                          value: .list([
                              SliceValue.ListItem(id: "1", title: "Approve Acme"),
                              SliceValue.ListItem(id: "2", title: "Review Contoso")
                          ]),
                          deepLink: nil, refreshedAt: Date(timeIntervalSince1970: 1))
            ],
            refreshedAt: Date(timeIntervalSince1970: 1)
        )
    }

    private var kitchenLarge: WidgetLayout {
        let binding = { DataBinding(bundleId: "com.example.Dashboard", sliceId: $0) }
        return WidgetLayout(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "kitchen",
            family: .large,
            cells: [
                Cell(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
                     origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                     component: .header(.init(title: "Sales", subtitle: "Today",
                                              accent: .fromApp))),
                Cell(id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
                     origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                     component: .count(.init(binding: binding("pending"),
                                             caption: "Pending", accent: .fromApp))),
                Cell(id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
                     origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                     component: .metric(.init(binding: binding("revenue"),
                                              caption: "Revenue", accent: .fromApp))),
                Cell(id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
                     origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 2, rows: 1),
                     component: .status(.init(binding: binding("health"),
                                              accent: .fromApp))),
                Cell(id: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!,
                     origin: GridPoint(col: 2, row: 2), span: GridSize(cols: 2, rows: 1),
                     component: .progress(.init(binding: binding("quota"),
                                                style: .bar, accent: .fromApp))),
                Cell(id: UUID(uuidString: "00000000-0000-0000-0000-000000000015")!,
                     origin: GridPoint(col: 0, row: 3), span: GridSize(cols: 4, rows: 1),
                     component: .list(.init(binding: binding("items"),
                                            maxRows: 2, accent: .fromApp)))
            ],
            background: .system,
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0)
        )
    }

    @MainActor
    func testSmallDefault() {
        let v = render(LayoutStore.defaultLayout(for: .small), size: CGSize(width: 170, height: 170))
        snapshot(v, size: CGSize(width: 170, height: 170))
    }

    @MainActor
    func testMediumDefault() {
        let v = render(LayoutStore.defaultLayout(for: .medium), size: CGSize(width: 364, height: 170))
        snapshot(v, size: CGSize(width: 364, height: 170))
    }

    @MainActor
    func testLargeKitchen() {
        let v = render(kitchenLarge, size: CGSize(width: 364, height: 382))
        snapshot(v, size: CGSize(width: 364, height: 382))
    }

    @MainActor
    func testExtraLargeDefault() {
        let v = render(LayoutStore.defaultLayout(for: .extraLarge), size: CGSize(width: 750, height: 382))
        snapshot(v, size: CGSize(width: 750, height: 382))
    }

    @MainActor
    func testXLPortraitDefault() {
        let v = render(LayoutStore.defaultLayout(for: .xlPortrait), size: CGSize(width: 500, height: 700))
        snapshot(v, size: CGSize(width: 500, height: 700))
    }
}
#endif
