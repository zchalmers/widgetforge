import Foundation

public struct AppCapabilityManifest: Codable, Sendable, Equatable {
    public static let currentSchemaVersion: Int = 1

    public let schemaVersion: Int
    public let bundleId: String
    public let displayName: String
    public let accentHex: String
    public let iconAssetName: String?
    public let deepLinkScheme: String
    public let slices: [DataSlice]
    public let refreshedAt: Date

    public init(schemaVersion: Int = AppCapabilityManifest.currentSchemaVersion,
                bundleId: String, displayName: String, accentHex: String,
                iconAssetName: String?, deepLinkScheme: String,
                slices: [DataSlice], refreshedAt: Date) {
        self.schemaVersion = schemaVersion
        self.bundleId = bundleId
        self.displayName = displayName
        self.accentHex = accentHex
        self.iconAssetName = iconAssetName
        self.deepLinkScheme = deepLinkScheme
        self.slices = slices
        self.refreshedAt = refreshedAt
    }
}
