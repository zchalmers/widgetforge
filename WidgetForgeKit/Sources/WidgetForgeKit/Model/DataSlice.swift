import Foundation

public struct DataSlice: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let displayName: String
    public let kind: SliceKind
    public let value: SliceValue
    public let deepLink: URL?
    public let refreshedAt: Date

    public init(id: String, displayName: String, kind: SliceKind, value: SliceValue, deepLink: URL?, refreshedAt: Date) {
        self.id = id
        self.displayName = displayName
        self.kind = kind
        self.value = value
        self.deepLink = deepLink
        self.refreshedAt = refreshedAt
    }
}
