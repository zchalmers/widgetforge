import Foundation

public struct AppRegistry: Sendable, Equatable {
    public struct Entry: Sendable, Equatable, Identifiable, Codable {
        public let bundleId: String
        public let displayName: String
        public let scheme: String
        public let accentHex: String
        public let iconAssetName: String?
        public let confirmed: Bool
        public var id: String { bundleId }
        public init(bundleId: String,
                    displayName: String,
                    scheme: String,
                    accentHex: String,
                    iconAssetName: String?,
                    confirmed: Bool) {
            self.bundleId = bundleId
            self.displayName = displayName
            self.scheme = scheme
            self.accentHex = accentHex
            self.iconAssetName = iconAssetName
            self.confirmed = confirmed
        }
    }

    public let entries: [Entry]

    public init(entries: [Entry]) { self.entries = entries }

    public func entry(for bundleId: String) -> Entry? {
        entries.first(where: { $0.bundleId == bundleId })
    }

    /// Stable list of URL schemes for `LSApplicationQueriesSchemes` generation.
    /// Order matches `entries`; a build-time Run Script phase in the app target
    /// consumes this to write Info.plist. See `AppRegistryPlistDriftTests`.
    public var querySchemes: [String] { entries.map(\.scheme) }

    public static let `default` = AppRegistry(entries: [
        .init(bundleId: "com.example.it.inbox", displayName: "Inbox",
              scheme: "inbox", accentHex: "#F9B71A",
              iconAssetName: "approveit", confirmed: true),
        .init(bundleId: "com.example.it.inbox.internal", displayName: "Inbox",
              scheme: "inbox", accentHex: "#F9B71A",
              iconAssetName: "approveit", confirmed: true),
        .init(bundleId: "com.example.Dashboard", displayName: "Pipeline",
              scheme: "pipeline", accentHex: "#3ECCB8",
              iconAssetName: "dashboard", confirmed: true),
        .init(bundleId: "com.example.Dashboard.internal", displayName: "Pipeline",
              scheme: "pipeline", accentHex: "#3ECCB8",
              iconAssetName: "dashboard", confirmed: true),
        .init(bundleId: "com.example.DealApproval", displayName: "Review Queue",
              scheme: "reviewqueue", accentHex: "#9871FA",
              iconAssetName: "reviewqueue", confirmed: true),
        .init(bundleId: "com.example.DealApproval.dev", displayName: "Review Queue",
              scheme: "reviewqueue", accentHex: "#9871FA",
              iconAssetName: "reviewqueue", confirmed: true),
        .init(bundleId: "com.example.example.fitwidget", displayName: "Wellness",
              scheme: "fitwidget", accentHex: "#4ACF6B",
              iconAssetName: "fitwidget", confirmed: true),
        .init(bundleId: "com.example.example.fitwidget.internal", displayName: "Wellness",
              scheme: "fitwidget", accentHex: "#4ACF6B",
              iconAssetName: "fitwidget", confirmed: true),
        .init(bundleId: "com.example.example.fitwidget.internals", displayName: "Wellness",
              scheme: "fitwidget", accentHex: "#4ACF6B",
              iconAssetName: "fitwidget", confirmed: true),
        .init(bundleId: "com.example.Time Tracker.internal", displayName: "Time Tracker",
              scheme: "timetracker", accentHex: "#1EB2A6",
              iconAssetName: "timetracker", confirmed: true),
        .init(bundleId: "com.example.Time Tracker.internal.dev", displayName: "Time Tracker",
              scheme: "timetracker", accentHex: "#1EB2A6",
              iconAssetName: "timetracker", confirmed: true),
        .init(bundleId: "com.example.example.Milestones", displayName: "Milestones",
              scheme: "milestones", accentHex: "#E8368F",
              iconAssetName: "celebrate", confirmed: true),
        .init(bundleId: "com.example.example.Milestones.dev", displayName: "Milestones",
              scheme: "milestones", accentHex: "#E8368F",
              iconAssetName: "celebrate", confirmed: true),
        .init(bundleId: "com.example.timeoff", displayName: "Time Off",
              scheme: "timeoff", accentHex: "#049F9A",
              iconAssetName: "timeoff", confirmed: true),
        .init(bundleId: "com.example.timeoff.GIT.internal", displayName: "Time Off",
              scheme: "timeoff", accentHex: "#049F9A",
              iconAssetName: "timeoff", confirmed: true)
    ])
}
