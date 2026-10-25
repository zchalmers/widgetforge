#if canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import WidgetForgeKit

final class LeafViewsPart1Tests: XCTestCase {
    func testConstructsWithoutCrash() {
        let binding = DataBinding(bundleId: "com.example.Dashboard", sliceId: "pending")
        _ = HeaderView(config: .init(title: "Sales", subtitle: "Q3", accent: .fromApp)).body
        _ = CountView(config: .init(binding: binding, caption: "Pending", accent: .fromApp), slice: nil).body
        _ = MetricView(config: .init(binding: binding, caption: "Revenue", accent: .token(.teal)), slice: nil).body
        _ = StatusView(config: .init(binding: binding, accent: .fromApp), slice: nil).body
    }

    func testResolvesSliceValues() {
        let binding = DataBinding(bundleId: "com.example.Dashboard", sliceId: "pending")
        let slice = DataSlice(id: "pending", displayName: "Pending", kind: .count,
                              value: .count(9), deepLink: nil,
                              refreshedAt: Date(timeIntervalSince1970: 0))
        _ = CountView(config: .init(binding: binding, caption: nil, accent: .fromApp), slice: slice).body
    }
}
#endif
