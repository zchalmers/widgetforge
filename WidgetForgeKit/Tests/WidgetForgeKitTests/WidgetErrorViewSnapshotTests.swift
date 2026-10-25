#if canImport(SwiftUI) && os(macOS)
import XCTest
import SwiftUI
import SnapshotTesting
import AppKit
@testable import WidgetForgeKit

final class WidgetErrorViewSnapshotTests: XCTestCase {
    @MainActor
    private func snapshot<V: View>(_ view: V, size: CGSize, record: Bool = false,
                                    file: StaticString = #file, testName: String = #function, line: UInt = #line) {
        let host = NSHostingView(rootView: view)
        host.frame = CGRect(origin: .zero, size: size)
        assertSnapshot(of: host, as: .image, record: record, file: file, testName: testName, line: line)
    }

    private let layoutId = UUID(uuidString: "EEEEEEEE-0000-0000-0000-000000000001")!

    @MainActor
    private func render(_ reason: RecoveryReason) -> some View {
        WidgetErrorView(kind: .WFMedium, reason: reason, layoutId: layoutId)
    }

    @MainActor
    func testNoManifests() {
        snapshot(render(.noManifests), size: CGSize(width: 364, height: 170))
    }

    @MainActor
    func testMissingSlice() {
        snapshot(render(.missingSlice), size: CGSize(width: 364, height: 170))
    }

    @MainActor
    func testMissingLayout() {
        snapshot(render(.missingLayout), size: CGSize(width: 364, height: 170))
    }

    @MainActor
    func testReadFailure() {
        snapshot(render(.readFailure), size: CGSize(width: 364, height: 170))
    }

    @MainActor
    func testContainerUnreadable() {
        snapshot(render(.containerUnreadable), size: CGSize(width: 364, height: 170))
    }
}
#endif
