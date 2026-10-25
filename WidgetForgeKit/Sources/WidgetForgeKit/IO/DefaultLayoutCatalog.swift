import Foundation

/// Generated persona-tailored default layouts seeded on first launch.
/// Each binds to real app slices (KnownSliceCatalog) and renders live data
/// when a publisher's manifest exists, or a clean empty state otherwise.
///
/// Bindings use the REAL slice vocabulary each app's `WidgetForgeBridge`
/// publishes (see `KnownSliceCatalog` and `SampleData`). Bundle ids are the
/// canonical (prod) ids; `RenderContext` resolves installed internal/dev
/// variants automatically.
public enum DefaultLayoutCatalog {
    /// Stable id for a catalog layout so re-seeding is idempotent.
    public static func id(family: LayoutFamily, name: String) -> UUID {
        // Precomputed UUIDv5 (namespace 6d1f… , "family/name").
        catalogIds["\(family.rawValue)/\(name)"] ?? UUID()
    }

    private static let catalogIds: [String: UUID] = [
        "small/Approvals Command": UUID(uuidString: "ABC27C0F-E314-5B0B-A240-58CDB87624EC")!,
        "small/Sales Pipeline": UUID(uuidString: "4FC7BC87-0B34-5C3A-8484-6FFEACCFD346")!,
        "small/Timesheet Status": UUID(uuidString: "0EED7A79-F619-5990-9B90-CF0741AB8822")!,
        "small/Team Away": UUID(uuidString: "8942D6EC-283C-594B-B924-49453F4AD937")!,
        "medium/Approvals Command": UUID(uuidString: "767670A3-6CEA-5505-9636-F1D65BF644BF")!,
        "medium/Sales Pipeline": UUID(uuidString: "0940D011-60EE-54AA-A4EC-C9F6469E0588")!,
        "medium/My Time": UUID(uuidString: "C198A75D-3658-515E-83FE-88A4A59A8EC0")!,
        "medium/Team Away": UUID(uuidString: "95DADC6D-68DA-5197-8453-213B34523B8E")!,
        "large/Manager Morning Brief": UUID(uuidString: "897C554A-C62B-5A8E-9101-B5F4C5D8DD06")!,
        "large/Sales Pipeline": UUID(uuidString: "69856EA9-2676-52AA-9C23-4916860DA8CE")!,
        "large/My Time": UUID(uuidString: "3E50189C-BBDD-5F3B-BDD0-323DC58D50E8")!,
        "large/Wellbeing": UUID(uuidString: "89640B76-5792-5AF7-9320-A8EF8FA17BD4")!,
        "extraLarge/Exec Command Center": UUID(uuidString: "B452F76E-49BD-5C8D-8001-6376B85BC3C7")!,
        "extraLarge/Sales War Room": UUID(uuidString: "ADF595CD-344E-528B-A1EE-BD16CD838B11")!,
        "extraLarge/My Full Day": UUID(uuidString: "63BAB8CA-F404-5938-B6B5-6863EF01BF18")!,
        "xlPortrait/My Workday": UUID(uuidString: "226C4F67-706D-54D9-B3AE-92496E30C8FE")!,
        "xlPortrait/Wellness Wellbeing": UUID(uuidString: "EE1C172E-3152-500F-9227-124D8CD9327F")!,
        "xlPortrait/Recognition Feed": UUID(uuidString: "8FC077C5-F68F-5C7C-B1A7-1FB3843690E2")!,
    ]

    // MARK: - Canonical bundle ids (prod). RenderContext resolves variants.
    private static let approveIT = "com.example.it.inbox"
    private static let dealManager = "com.example.Dashboard"
    private static let dealApproval = "com.example.DealApproval"
    private static let fitWidget = "com.example.example.fitwidget"
    private static let catsXT = "com.example.Time Tracker.internal"
    private static let celebrate = "com.example.example.Milestones"
    private static let leaveRequest = "com.example.timeoff"

    private static func bind(_ bundle: String, _ slice: String) -> DataBinding {
        DataBinding(bundleId: bundle, sliceId: slice)
    }

    /// All default layouts, in display order (by family, then design order).
    public static func all() -> [WidgetLayout] {
        [
            smallApprovalsCommand(),
            smallSalesPipeline(),
            smallTimesheetStatus(),
            smallTeamAway(),
            mediumApprovalsCommand(),
            mediumSalesPipeline(),
            mediumMyTime(),
            mediumTeamAway(),
            largeManagerMorningBrief(),
            largeSalesPipeline(),
            largeMyTime(),
            largeWellbeing(),
            extraLargeExecCommandCenter(),
            extraLargeSalesWarRoom(),
            extraLargeMyFullDay(),
            xlPortraitMyWorkday(),
            xlPortraitWellnessWellbeing(),
            xlPortraitRecognitionFeed(),
        ]
    }

    // MARK: - Small

    // Approvals Command — manager — how many approvals are waiting on you right now.
    private static func smallApprovalsCommand() -> WidgetLayout {
        layout(.small, "Approvals Command", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 1),
                 component: .header(HeaderConfig(title: "Approvals", subtitle: nil, accent: .token(.amber)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(approveIT, "pendingCount"), caption: "Waiting on you", accent: .fromApp))),
        ])
    }

    // Sales Pipeline — sales — full-bleed pipeline value with trend from Review Queue.
    private static func smallSalesPipeline() -> WidgetLayout {
        layout(.small, "Sales Pipeline", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 2),
                 component: .metric(MetricConfig(binding: bind(dealApproval, "pipelineValue"), caption: "Pipeline", accent: .fromApp))),
        ])
    }

    // Timesheet Status — time — Time Tracker week status pill.
    private static func smallTimesheetStatus() -> WidgetLayout {
        layout(.small, "Timesheet Status", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 1),
                 component: .header(HeaderConfig(title: "My Time", subtitle: nil, accent: .token(.teal)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .status(StatusConfig(binding: bind(catsXT, "weeklyStatus"), accent: .fromApp))),
        ])
    }

    // Team Away — general — leave balance metric + remaining-vacation ring from Time Off.
    private static func smallTeamAway() -> WidgetLayout {
        layout(.small, "Team Away", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 1, rows: 2),
                 component: .metric(MetricConfig(binding: bind(leaveRequest, "availableBalance"), caption: "Balance", accent: .fromApp))),
            Cell(origin: GridPoint(col: 1, row: 0), span: GridSize(cols: 1, rows: 2),
                 component: .progress(ProgressConfig(binding: bind(leaveRequest, "balanceRemaining"), style: .ring, accent: .fromApp))),
        ])
    }

    // MARK: - Medium

    // Approvals Command — manager — pending count + approvals health.
    private static func mediumApprovalsCommand() -> WidgetLayout {
        layout(.medium, "Approvals Command", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Approvals", subtitle: "What needs you today", accent: .token(.amber)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(approveIT, "pendingCount"), caption: "Pending", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .status(StatusConfig(binding: bind(approveIT, "approvalStatus"), accent: .fromApp))),
        ])
    }

    // Sales Pipeline — sales — pending quotes + pipeline value.
    private static func mediumSalesPipeline() -> WidgetLayout {
        layout(.medium, "Sales Pipeline", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Sales Pipeline", subtitle: "Quotes & value", accent: .token(.teal)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(dealApproval, "pendingQuoteCount"), caption: "Pending quotes", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(dealApproval, "pipelineValue"), caption: "Pipeline value", accent: .fromApp))),
        ])
    }

    // My Time — time — hours today + remaining-today progress.
    private static func mediumMyTime() -> WidgetLayout {
        layout(.medium, "My Time", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "My Time", subtitle: "Today", accent: .token(.violet)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(catsXT, "hoursToday"), caption: "Logged", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .progress(ProgressConfig(binding: bind(catsXT, "hoursRemainingToday"), style: .bar, accent: .fromApp))),
        ])
    }

    // Team Away — manager — leave balance + time-accounts list.
    private static func mediumTeamAway() -> WidgetLayout {
        layout(.medium, "Team Away", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Time Off", subtitle: "Your balances", accent: .token(.mint)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(leaveRequest, "availableBalance"), caption: "Available", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .list(ListConfig(binding: bind(leaveRequest, "topAccounts"), maxRows: 2, accent: .fromApp))),
        ])
    }

    // MARK: - Large

    // Manager Morning Brief — manager — approvals, pipeline, time status, and the approvals queue.
    private static func largeManagerMorningBrief() -> WidgetLayout {
        layout(.large, "Manager Morning Brief", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Morning Brief", subtitle: "Approvals, deals & time", accent: .token(.violet)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(approveIT, "pendingCount"), caption: "Pending Approvals", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(dealApproval, "pipelineValue"), caption: "Pipeline Value", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 4, rows: 1),
                 component: .status(StatusConfig(binding: bind(catsXT, "weeklyStatus"), accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 3), span: GridSize(cols: 4, rows: 1),
                 component: .list(ListConfig(binding: bind(approveIT, "topApprovals"), maxRows: 2, accent: .fromApp))),
        ])
    }

    // Sales Pipeline — sales — pending quotes + pipeline value with the top-quotes queue.
    private static func largeSalesPipeline() -> WidgetLayout {
        layout(.large, "Sales Pipeline", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Sales Pipeline", subtitle: "Review Queue", accent: .token(.teal)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(dealApproval, "pendingQuoteCount"), caption: "Pending Quotes", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(dealApproval, "pipelineValue"), caption: "Pipeline Value", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 4, rows: 2),
                 component: .list(ListConfig(binding: bind(dealApproval, "topQuotes"), maxRows: 5, accent: .fromApp))),
        ])
    }

    // My Time — time — hours today beside remaining-today ring, weekly remaining, week status.
    private static func largeMyTime() -> WidgetLayout {
        layout(.large, "My Time", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "My Time", subtitle: "This week", accent: .token(.amber)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(catsXT, "hoursToday"), caption: "Today", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 2),
                 component: .progress(ProgressConfig(binding: bind(catsXT, "hoursRemainingToday"), style: .ring, accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(catsXT, "weeklyRemaining"), caption: "Week Left", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 3), span: GridSize(cols: 4, rows: 1),
                 component: .status(StatusConfig(binding: bind(catsXT, "weeklyStatus"), accent: .fromApp))),
        ])
    }

    // Wellbeing — wellbeing — Wellness board: active challenges + fitness status, steps & bike today.
    private static func largeWellbeing() -> WidgetLayout {
        layout(.large, "Wellbeing", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Wellbeing", subtitle: "Wellness", accent: .token(.mint)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(fitWidget, "activeChallenges"), caption: "Active Challenges", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(fitWidget, "stepsToday"), caption: "Steps Today", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(fitWidget, "bikeToday"), caption: "Bike Today", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 2), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(fitWidget, "stepsGoal"), caption: "Steps Goal", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 3), span: GridSize(cols: 4, rows: 1),
                 component: .status(StatusConfig(binding: bind(fitWidget, "fitnessStatus"), accent: .fromApp))),
        ])
    }

    // MARK: - Extra Large

    // Exec Command Center — exec — approvals load, pipeline value, time status, deals awaiting.
    private static func extraLargeExecCommandCenter() -> WidgetLayout {
        layout(.extraLarge, "Exec Command Center", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Command Center", subtitle: "Approvals - Pipeline - Time", accent: .token(.violet)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(approveIT, "pendingCount"), caption: "Pending Approvals", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(dealApproval, "pipelineValue"), caption: "Pipeline Value", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 2, rows: 1),
                 component: .status(StatusConfig(binding: bind(catsXT, "weeklyStatus"), accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 2), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(dealApproval, "pendingQuoteCount"), caption: "Pending Quotes", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 3), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Top Quotes", subtitle: nil, accent: .token(.teal)))),
            Cell(origin: GridPoint(col: 0, row: 4), span: GridSize(cols: 4, rows: 2),
                 component: .list(ListConfig(binding: bind(dealApproval, "topQuotes"), maxRows: 5, accent: .fromApp))),
        ])
    }

    // Sales War Room — sales — pipeline + approval KPIs down the left, deal queue on the right, Pipeline tile.
    private static func extraLargeSalesWarRoom() -> WidgetLayout {
        layout(.extraLarge, "Sales War Room", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Sales War Room", subtitle: "Live pipeline + approval queue", accent: .token(.coral)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(dealApproval, "pendingQuoteCount"), caption: "Pending Quotes", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(dealApproval, "pipelineValue"), caption: "Pipeline Value", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 3), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(dealManager, "actionRequiredCount"), caption: "Deals Needing Action", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 4), span: GridSize(cols: 2, rows: 1),
                 component: .status(StatusConfig(binding: bind(dealApproval, "quoteHealth"), accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 5), span: GridSize(cols: 2, rows: 1),
                 component: .appTile(AppTileConfig(bundleId: dealManager, accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 5),
                 component: .list(ListConfig(binding: bind(dealApproval, "topQuotes"), maxRows: 6, accent: .fromApp))),
        ])
    }

    // My Full Day — general — time progress, approvals, quotes, leave balance, and the approvals queue.
    private static func extraLargeMyFullDay() -> WidgetLayout {
        layout(.extraLarge, "My Full Day", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "My Full Day", subtitle: "Time, Approvals & Leave", accent: .token(.mint)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 2),
                 component: .progress(ProgressConfig(binding: bind(catsXT, "hoursRemainingToday"), style: .ring, accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(approveIT, "pendingCount"), caption: "Pending Approvals", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 2), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(dealApproval, "pendingQuoteCount"), caption: "Pending Quotes", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 3), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(leaveRequest, "availableBalance"), caption: "Leave Balance", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 3), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(catsXT, "hoursToday"), caption: "Hours Today", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 4), span: GridSize(cols: 4, rows: 2),
                 component: .list(ListConfig(binding: bind(approveIT, "topApprovals"), maxRows: 5, accent: .fromApp))),
        ])
    }

    // MARK: - XL Portrait

    // My Workday — time — approvals + hours today up top, remaining-today progress, then the approvals queue.
    private static func xlPortraitMyWorkday() -> WidgetLayout {
        layout(.xlPortrait, "My Workday", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "My Workday", subtitle: "Approvals, hours, and queue", accent: .token(.teal)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(approveIT, "pendingCount"), caption: "Pending Approvals", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(catsXT, "weeklyRemaining"), caption: "Week Remaining", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 4, rows: 1),
                 component: .metric(MetricConfig(binding: bind(catsXT, "hoursToday"), caption: "Hours Today", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 3), span: GridSize(cols: 4, rows: 1),
                 component: .progress(ProgressConfig(binding: bind(catsXT, "hoursRemainingToday"), style: .bar, accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 4), span: GridSize(cols: 4, rows: 2),
                 component: .list(ListConfig(binding: bind(approveIT, "topApprovals"), maxRows: 4, accent: .fromApp))),
        ])
    }

    // Wellness Wellbeing — wellbeing — steps & bike today, challenges & goals, fitness status.
    private static func xlPortraitWellnessWellbeing() -> WidgetLayout {
        layout(.xlPortrait, "Wellness Wellbeing", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Wellbeing", subtitle: "Steps, biking, and challenges", accent: .token(.mint)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(fitWidget, "stepsToday"), caption: "Steps Today", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(fitWidget, "activeChallenges"), caption: "Active Challenges", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(fitWidget, "bikeToday"), caption: "Bike Today", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 2), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(fitWidget, "stepsGoal"), caption: "Steps Goal", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 3), span: GridSize(cols: 2, rows: 1),
                 component: .metric(MetricConfig(binding: bind(fitWidget, "bikeGoal"), caption: "Bike Goal", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 3), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(fitWidget, "activeChallenges"), caption: "Challenges", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 4), span: GridSize(cols: 4, rows: 2),
                 component: .status(StatusConfig(binding: bind(fitWidget, "fitnessStatus"), accent: .fromApp))),
        ])
    }

    // Recognition Feed — culture — Milestones: upcoming count + health, today, and coming-up.
    private static func xlPortraitRecognitionFeed() -> WidgetLayout {
        layout(.xlPortrait, "Recognition Feed", [
            Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Recognition", subtitle: "Milestones and celebrations", accent: .token(.violet)))),
            Cell(origin: GridPoint(col: 0, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: bind(celebrate, "upcomingCount"), caption: "Upcoming", accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1), span: GridSize(cols: 2, rows: 1),
                 component: .status(StatusConfig(binding: bind(celebrate, "celebrationStatus"), accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2), span: GridSize(cols: 4, rows: 2),
                 component: .list(ListConfig(binding: bind(celebrate, "todayCelebrations"), maxRows: 4, accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 4), span: GridSize(cols: 4, rows: 2),
                 component: .list(ListConfig(binding: bind(celebrate, "nextCelebrations"), maxRows: 4, accent: .fromApp))),
        ])
    }

    // MARK: - Builder

    private static func layout(_ family: LayoutFamily, _ name: String, _ cells: [Cell]) -> WidgetLayout {
        WidgetLayout(
            id: id(family: family, name: name),
            name: name,
            family: family,
            cells: cells,
            background: .system,
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0))
    }
}
