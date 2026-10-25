#if canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import WidgetForgeKit

final class LeafViewsPart2Tests: XCTestCase {
    func testConstructsWithoutCrash() {
        let binding = DataBinding(bundleId: "com.example.Dashboard", sliceId: "s")
        _ = ListView(config: .init(binding: binding, maxRows: 3, accent: .fromApp), slice: nil).body
        _ = WFProgressView(config: .init(binding: binding, style: .ring, accent: .fromApp), slice: nil).body
        _ = WFProgressView(config: .init(binding: binding, style: .bar, accent: .fromApp), slice: nil).body
        _ = AppTileView(config: .init(bundleId: "com.example.Dashboard", accent: .fromApp),
                        entry: AppRegistry.default.entry(for: "com.example.Dashboard")).body
    }

    func testListRespectsMaxRows() {
        let items = (0..<10).map { SliceValue.ListItem(id: "\($0)", title: "T\($0)") }
        let slice = DataSlice(id: "l", displayName: "L", kind: .list, value: .list(items),
                              deepLink: nil, refreshedAt: Date(timeIntervalSince1970: 0))
        let binding = DataBinding(bundleId: "com.example.Dashboard", sliceId: "l")
        _ = ListView(config: .init(binding: binding, maxRows: 3, accent: .fromApp), slice: slice).body
    }
}
#endif
