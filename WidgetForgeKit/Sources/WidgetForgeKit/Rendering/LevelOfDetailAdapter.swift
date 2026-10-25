#if canImport(SwiftUI)
import SwiftUI
#if os(iOS)
import WidgetKit
#endif

public enum WFLevelOfDetail: Sendable, Equatable, CaseIterable {
    case simplified
    case `default`
}

public struct LevelOfDetailReader<Content: View>: View {
    private let content: (WFLevelOfDetail) -> Content

    public init(@ViewBuilder content: @escaping (WFLevelOfDetail) -> Content) {
        self.content = content
    }

    public var body: some View {
        #if os(iOS)
        if #available(iOS 27.0, *) {
            LevelOfDetailBridge(content: content)
        } else {
            content(.default)
        }
        #else
        content(.default)
        #endif
    }
}

#if os(iOS)
@available(iOS 27.0, *)
private struct LevelOfDetailBridge<Content: View>: View {
    @Environment(\.levelOfDetail) private var systemLOD
    let content: (WFLevelOfDetail) -> Content

    var body: some View {
        content(map(systemLOD))
    }

    // Documented iOS 27 values (developer.apple.com/documentation/widgetkit/levelofdetail):
    // `.simplified` maps to our `.simplified`; any other value collapses to `.default`.
    private func map(_ lod: LevelOfDetail) -> WFLevelOfDetail {
        if lod == .simplified { return .simplified }
        return .default
    }
}
#endif

#endif
