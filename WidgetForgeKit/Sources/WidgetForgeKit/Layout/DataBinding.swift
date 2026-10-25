import Foundation

public struct DataBinding: Codable, Sendable, Hashable {
    public var bundleId: String
    public var sliceId: String
    public init(bundleId: String, sliceId: String) {
        self.bundleId = bundleId
        self.sliceId = sliceId
    }
}
