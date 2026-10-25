import Foundation

/// Public catalog of "known" slice ids that a Widget app publishes to the shared
/// container. Used when an app's manifest has not yet been written — so intents
/// and the layout editor can still pre-bind and surface something meaningful.
///
/// Mirror of what each Widget app's `WidgetForgeBridge` writes. Prior to this
/// commit, the same table lived file-privately in `WidgetForge/Editor/BindingPicker.swift`;
/// it now ships from WidgetForgeKit so App Intents on the WidgetForge app target
/// and the widget extension can share it.
public struct KnownSlice: Hashable, Sendable {
    public let sliceId: String
    public let displayName: String
    public let kind: SliceKind

    public init(sliceId: String, displayName: String, kind: SliceKind) {
        self.sliceId = sliceId
        self.displayName = displayName
        self.kind = kind
    }
}

public enum KnownSliceCatalog {
    /// Bundle-id → known slices. These MIRROR EXACTLY the slice ids and kinds
    /// each Widget app's `WidgetForgeBridge` actually publishes. Both prod and
    /// internal/dev variant ids map to the same slice set.
    public static let entries: [String: [KnownSlice]] = [
        "com.example.it.inbox": approveIT,
        "com.example.it.inbox.internal": approveIT,
        "com.example.Dashboard": dashboard,
        "com.example.Dashboard.internal": dashboard,
        "com.example.DealApproval": dealApproval,
        "com.example.DealApproval.dev": dealApproval,
        "com.example.example.fitwidget": fitWidget,
        "com.example.example.fitwidget.internal": fitWidget,
        "com.example.example.fitwidget.internals": fitWidget,
        "com.example.Time Tracker.internal": catsXT,
        "com.example.Time Tracker.internal.dev": catsXT,
        "com.example.example.Milestones": celebrate,
        "com.example.example.Milestones.dev": celebrate,
        "com.example.timeoff": leaveRequest,
        "com.example.timeoff.GIT.internal": leaveRequest
    ]

    private static let approveIT: [KnownSlice] = [
        KnownSlice(sliceId: "pendingCount", displayName: "Pending Approvals", kind: .count),
        KnownSlice(sliceId: "topApprovals", displayName: "Top Approvals", kind: .list),
        KnownSlice(sliceId: "approvalStatus", displayName: "Approvals Health", kind: .status)
    ]

    private static let dashboard: [KnownSlice] = [
        KnownSlice(sliceId: "actionRequiredCount", displayName: "Deals Needing Action", kind: .count),
        KnownSlice(sliceId: "topActionDeals", displayName: "Top Action Deals", kind: .list),
        KnownSlice(sliceId: "pipelineHealth", displayName: "Pipeline Health", kind: .status),
        KnownSlice(sliceId: "reaffirmProgress", displayName: "Reaffirmation Progress", kind: .progress)
    ]

    private static let dealApproval: [KnownSlice] = [
        KnownSlice(sliceId: "pendingQuoteCount", displayName: "Pending Quotes", kind: .count),
        KnownSlice(sliceId: "topQuotes", displayName: "Top Quotes", kind: .list),
        KnownSlice(sliceId: "pipelineValue", displayName: "Pipeline Value", kind: .metric),
        KnownSlice(sliceId: "quoteHealth", displayName: "Approval Health", kind: .status),
        KnownSlice(sliceId: "substituteQuoteCount", displayName: "Substitute Approvals", kind: .count),
        KnownSlice(sliceId: "topSubstituteQuotes", displayName: "Top Substitute Deals", kind: .list),
        KnownSlice(sliceId: "substitutePipelineValue", displayName: "Substitute Pipeline", kind: .metric),
        KnownSlice(sliceId: "substituteCoverage", displayName: "Coverage Load", kind: .status)
    ]

    private static let fitWidget: [KnownSlice] = [
        KnownSlice(sliceId: "activeChallenges", displayName: "Active Challenges", kind: .count),
        KnownSlice(sliceId: "fitnessStatus", displayName: "Fitness Status", kind: .status),
        KnownSlice(sliceId: "stepsGoal", displayName: "Daily Steps Goal", kind: .metric),
        KnownSlice(sliceId: "bikeGoal", displayName: "Daily Biking Goal", kind: .metric),
        KnownSlice(sliceId: "stepsToday", displayName: "Steps Today", kind: .metric),
        KnownSlice(sliceId: "bikeToday", displayName: "Bike Distance Today", kind: .metric)
    ]

    private static let catsXT: [KnownSlice] = [
        KnownSlice(sliceId: "hoursToday", displayName: "Hours Today", kind: .metric),
        KnownSlice(sliceId: "hoursRemainingToday", displayName: "Remaining Today", kind: .progress),
        KnownSlice(sliceId: "weeklyRemaining", displayName: "Weekly Remaining", kind: .metric),
        KnownSlice(sliceId: "weeklyStatus", displayName: "Week Status", kind: .status)
    ]

    private static let celebrate: [KnownSlice] = [
        KnownSlice(sliceId: "upcomingCount", displayName: "Upcoming Celebrations", kind: .count),
        KnownSlice(sliceId: "todayCelebrations", displayName: "Today", kind: .list),
        KnownSlice(sliceId: "nextCelebrations", displayName: "Coming Up", kind: .list),
        KnownSlice(sliceId: "celebrationStatus", displayName: "Celebrations Health", kind: .status)
    ]

    private static let leaveRequest: [KnownSlice] = [
        KnownSlice(sliceId: "availableBalance", displayName: "Available Balance", kind: .metric),
        KnownSlice(sliceId: "entitlementTotal", displayName: "Yearly Entitlement", kind: .metric),
        KnownSlice(sliceId: "balanceRemaining", displayName: "Vacation Remaining", kind: .progress),
        KnownSlice(sliceId: "topAccounts", displayName: "Time Accounts", kind: .list)
    ]

    public static func slices(for bundleId: String) -> [KnownSlice] {
        entries[bundleId] ?? []
    }

    /// All (bundleId, KnownSlice) pairs. Used by SliceEntity suggestions.
    public static func allPairs() -> [(bundleId: String, slice: KnownSlice)] {
        entries.flatMap { pair in
            pair.value.map { (bundleId: pair.key, slice: $0) }
        }
    }
}
