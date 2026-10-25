import Foundation

/// Preview-only sample data. Produces realistic `AppCapabilityManifest`s for
/// every registered Widget app so widget-gallery snapshots and in-app layout
/// previews render populated numbers and lists before a real publisher app has
/// run.
///
/// The slice ids and kinds here MIRROR EXACTLY what each app's
/// `WidgetForgeBridge` actually publishes (see the real vocabulary in each
/// `/IDEAS/app-groups-prototype/<app>/.../WidgetForgeBridge.swift`). Keeping
/// this aligned with the publishers is what makes an in-app preview match the
/// live widget instead of showing data that never arrives.
///
/// IMPORTANT: this data is never written to the shared container and never
/// shown on a live, configured widget. A live widget renders only real
/// published manifests (or a clean empty state). Sample data appears solely in
/// preview contexts — the WidgetKit gallery (`context.isPreview`) and the app's
/// editor / preview sheet — so users can evaluate a layout before choosing it.
public enum SampleData {
    /// Merges sample manifests under real ones: any app that has really
    /// published keeps its live data; apps that haven't yet are filled with
    /// sample data so the preview looks complete. Real data always wins.
    public static func merged(withReal real: [AppCapabilityManifest]) -> [AppCapabilityManifest] {
        var byBundle: [String: AppCapabilityManifest] = [:]
        for m in manifests() { byBundle[m.bundleId] = m }
        for m in real { byBundle[m.bundleId] = m } // real overrides sample
        return Array(byBundle.values)
    }

    /// All sample manifests, one per registered Widget app. Bundle ids are the
    /// canonical (prod) ids the default layouts bind to.
    public static func manifests(now: Date = Date()) -> [AppCapabilityManifest] {
        [
            // Inbox — pendingCount / topApprovals / approvalStatus
            manifest("com.example.it.inbox", "Inbox", "#F9B71A", "approveit", "inbox", now, [
                slice("pendingCount", "Pending Approvals", .count, .count(12), now),
                slice("approvalStatus", "Approvals Health", .status, .status(.warning, text: "12 waiting"), now),
                slice("topApprovals", "Top Approvals", .list, .list([
                    item("a1", "PR-2412 · Cloud migration SOW", "Priya Nadella"),
                    item("a2", "REQ-8830 · Contractor extension", "Marco Reus"),
                    item("a3", "PO-5521 · Datacenter hardware", "Aisha Bello"),
                    item("a4", "INV-1190 · Q3 travel reimb.", "Tomás Silva"),
                    item("a5", "PR-2418 · Security audit", "Lena Vogt"),
                ]), now),
            ]),
            // Pipeline (Dashboard) — actionRequiredCount / topActionDeals / pipelineHealth / reaffirmProgress
            manifest("com.example.Dashboard", "Pipeline", "#3ECCB8", "dashboard", "pipeline", now, [
                slice("actionRequiredCount", "Deals Needing Action", .count, .count(7), now),
                slice("pipelineHealth", "Pipeline Health", .status, .status(.warning, text: "7 deals need reaffirmation"), now),
                slice("reaffirmProgress", "Reaffirmation Progress", .progress, .progress(0.62, label: "31/50 up to date"), now),
                slice("topActionDeals", "Top Action Deals", .list, .list([
                    item("d1", "Volkswagen · S/4HANA rollout", "1.4M€"),
                    item("d2", "Siemens · Cloud renewal", "820K€"),
                    item("d3", "Allianz · Analytics expansion", "610K€"),
                    item("d4", "BMW · Ariba integration", "540K€"),
                    item("d5", "Bosch · SuccessFactors", "390K€"),
                ]), now),
            ]),
            // Review Queue — pendingQuoteCount / topQuotes / pipelineValue / quoteHealth (+ substitute set)
            manifest("com.example.DealApproval", "Review Queue", "#9871FA", "reviewqueue", "reviewqueue", now, [
                slice("pendingQuoteCount", "Pending Quotes", .count, .count(5), now),
                slice("pipelineValue", "Pipeline Value", .metric, .metric(4.2, unit: "M€", trend: .up), now),
                slice("quoteHealth", "Approval Health", .status, .status(.ok, text: "5 waiting"), now),
                slice("topQuotes", "Top Quotes", .list, .list([
                    item("q1", "Deal #4471 · Enterprise tier", "1.4M€ · 2d"),
                    item("q2", "Deal #4468 · Renewal uplift", "820K€ · 1d"),
                    item("q3", "Deal #4462 · Add-on modules", "260K€ · 4h"),
                    item("q4", "Deal #4459 · Multi-year", "3.1M€ · 3d"),
                    item("q5", "Deal #4455 · Pilot conversion", "95K€ · 6h"),
                ]), now),
                slice("substituteQuoteCount", "Substitute Approvals", .count, .count(2), now),
                slice("substitutePipelineValue", "Substitute Pipeline", .metric, .metric(1.1, unit: "M€", trend: .flat), now),
                slice("substituteCoverage", "Coverage Load", .status, .status(.ok, text: "2 covering"), now),
                slice("topSubstituteQuotes", "Top Substitute Deals", .list, .list([
                    item("sq1", "Deal #4451 · Regional expansion", "710K€ · 5d"),
                    item("sq2", "Deal #4449 · Support renewal", "180K€ · 2d"),
                ]), now),
            ]),
            // Wellness — activeChallenges / fitnessStatus / stepsGoal / bikeGoal / stepsToday / bikeToday (steps are METRICS)
            manifest("com.example.example.fitwidget", "Wellness", "#4ACF6B", "fitwidget", "fitwidget", now, [
                slice("activeChallenges", "Active Challenges", .count, .count(3), now),
                slice("fitnessStatus", "Fitness Status", .status, .status(.ok, text: "3 active challenges"), now),
                slice("stepsGoal", "Daily Steps Goal", .metric, .metric(10000, unit: "steps", trend: .flat), now),
                slice("bikeGoal", "Daily Biking Goal", .metric, .metric(15, unit: "km", trend: .flat), now),
                slice("stepsToday", "Steps Today", .metric, .metric(8342, unit: "steps", trend: .flat), now),
                slice("bikeToday", "Bike Distance Today", .metric, .metric(6.4, unit: "km", trend: .up), now),
            ]),
            // Time Tracker — hoursToday / hoursRemainingToday / weeklyRemaining / weeklyStatus
            manifest("com.example.Time Tracker.internal", "Time Tracker", "#1EB2A6", "timetracker", "timetracker", now, [
                slice("hoursToday", "Hours Today", .metric, .metric(6.5, unit: "h recorded", trend: nil), now),
                slice("hoursRemainingToday", "Remaining Today", .progress, .progress(0.81, label: "6.5 / 8h"), now),
                slice("weeklyRemaining", "Weekly Remaining", .metric, .metric(8.5, unit: "h", trend: .down), now),
                slice("weeklyStatus", "Week Status", .status, .status(.warning, text: "8.5h remaining"), now),
            ]),
            // Milestones — upcomingCount / todayCelebrations / nextCelebrations / celebrationStatus
            manifest("com.example.example.Milestones", "Milestones", "#E8368F", "celebrate", "milestones", now, [
                slice("upcomingCount", "Upcoming Celebrations", .count, .count(6), now),
                slice("celebrationStatus", "Celebrations Health", .status, .status(.ok, text: "2 today"), now),
                slice("todayCelebrations", "Today", .list, .list([
                    item("c1", "Nadia Rahman", "Birthday"),
                    item("c2", "Marcus Reid", "10 year anniversary"),
                ]), now),
                slice("nextCelebrations", "Coming Up", .list, .list([
                    item("n1", "Carl Jensen", "Birthday · Thu"),
                    item("n2", "Wei Zhang", "Birthday · Fri"),
                    item("n3", "Elena Popov", "5 year anniversary · Mon"),
                    item("n4", "Sofia Costa", "Birthday · Mon"),
                ]), now),
            ]),
            // Time Off — availableBalance / entitlementTotal / balanceRemaining / topAccounts
            manifest("com.example.timeoff", "Time Off", "#049F9A", "timeoff", "timeoff", now, [
                slice("availableBalance", "Available Balance", .metric, .metric(14.5, unit: "days", trend: .flat), now),
                slice("entitlementTotal", "Yearly Entitlement", .metric, .metric(25, unit: "days", trend: .flat), now),
                slice("balanceRemaining", "Vacation Remaining", .progress, .progress(0.58, label: "14.5 / 25 days"), now),
                slice("topAccounts", "Time Accounts", .list, .list([
                    item("ta1", "Annual Leave", "14.5 days"),
                    item("ta2", "Sick Leave", "8.0 days"),
                    item("ta3", "Personal Days", "3.0 days"),
                ]), now),
            ]),
        ]
    }

    // MARK: - Builders

    private static func slice(_ id: String, _ name: String, _ kind: SliceKind,
                              _ value: SliceValue, _ now: Date) -> DataSlice {
        DataSlice(id: id, displayName: name, kind: kind, value: value, deepLink: nil, refreshedAt: now)
    }

    private static func item(_ id: String, _ title: String, _ subtitle: String? = nil) -> SliceValue.ListItem {
        SliceValue.ListItem(id: id, title: title, subtitle: subtitle)
    }

    private static func manifest(_ bundleId: String, _ name: String, _ hex: String,
                                 _ icon: String, _ scheme: String, _ now: Date,
                                 _ slices: [DataSlice]) -> AppCapabilityManifest {
        AppCapabilityManifest(bundleId: bundleId, displayName: name, accentHex: hex,
                              iconAssetName: icon, deepLinkScheme: scheme,
                              slices: slices, refreshedAt: now)
    }
}
