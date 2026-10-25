import Foundation
import SwiftUI
import WidgetForgeKit
import AppIntents

// MARK: - Count

/// "How many pending in <app>" → "You have N pending in <app>."
public struct ShowWidgetCountIntent: AppIntent {
    public static let title: LocalizedStringResource = "Show Widget Count"
    public static let description = IntentDescription("Reads the first count-kind slice for a Widget app.")

    @Parameter(title: "App", requestValueDialog: IntentDialog("Which Widget app?"))
    public var app: PublishingAppEntity

    public init() {}
    public init(app: PublishingAppEntity) { self.app = app }

    public static var parameterSummary: some ParameterSummary {
        Summary("How many pending in \(\.$app)")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let snap = WidgetIntentContext.snapshot(for: app.id, kind: .count) else {
            return .result(
                dialog: IntentDialog("\(app.displayName) hasn't published a count yet."),
                view: EmptySnippetView(text: "\(app.displayName) hasn't published a count yet.")
            )
        }
        return .result(
            dialog: IntentDialog("\(WidgetIntentContext.spokenDialog(for: snap))"),
            view: CountSnippetView(snapshot: snap)
        )
    }
}

// MARK: - List

/// "Show my <app> queue" → speaks top-N item titles.
public struct ShowWidgetListIntent: AppIntent {
    public static let title: LocalizedStringResource = "Show Widget List"
    public static let description = IntentDescription("Reads the first list-kind slice for a Widget app.")

    @Parameter(title: "App", requestValueDialog: IntentDialog("Which Widget app?"))
    public var app: PublishingAppEntity

    public init() {}
    public init(app: PublishingAppEntity) { self.app = app }

    public static var parameterSummary: some ParameterSummary {
        Summary("Show my \(\.$app) queue")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let snap = WidgetIntentContext.snapshot(for: app.id, kind: .list) else {
            return .result(
                dialog: IntentDialog("\(app.displayName) hasn't published a list yet."),
                view: EmptySnippetView(text: "\(app.displayName) hasn't published a list yet.")
            )
        }
        return .result(
            dialog: IntentDialog("\(WidgetIntentContext.spokenDialog(for: snap))"),
            view: ListSnippetView(snapshot: snap)
        )
    }
}

// MARK: - Status

/// "Status of <app>" → speaks status label + text.
public struct ShowWidgetStatusIntent: AppIntent {
    public static let title: LocalizedStringResource = "Show Widget Status"
    public static let description = IntentDescription("Reads the first status-kind slice for a Widget app.")

    @Parameter(title: "App", requestValueDialog: IntentDialog("Which Widget app?"))
    public var app: PublishingAppEntity

    public init() {}
    public init(app: PublishingAppEntity) { self.app = app }

    public static var parameterSummary: some ParameterSummary {
        Summary("Status of \(\.$app)")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let snap = WidgetIntentContext.snapshot(for: app.id, kind: .status) else {
            return .result(
                dialog: IntentDialog("\(app.displayName) hasn't published a status yet."),
                view: EmptySnippetView(text: "\(app.displayName) hasn't published a status yet.")
            )
        }
        return .result(
            dialog: IntentDialog("\(WidgetIntentContext.spokenDialog(for: snap))"),
            view: StatusSnippetView(snapshot: snap)
        )
    }
}

// MARK: - Metric

/// "<app> metric" → speaks value + unit + trend.
public struct ShowWidgetMetricIntent: AppIntent {
    public static let title: LocalizedStringResource = "Show Widget Metric"
    public static let description = IntentDescription("Reads the first metric-kind slice for a Widget app.")

    @Parameter(title: "App", requestValueDialog: IntentDialog("Which Widget app?"))
    public var app: PublishingAppEntity

    public init() {}
    public init(app: PublishingAppEntity) { self.app = app }

    public static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$app) metric")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let snap = WidgetIntentContext.snapshot(for: app.id, kind: .metric) else {
            return .result(
                dialog: IntentDialog("\(app.displayName) hasn't published a metric yet."),
                view: EmptySnippetView(text: "\(app.displayName) hasn't published a metric yet.")
            )
        }
        return .result(
            dialog: IntentDialog("\(WidgetIntentContext.spokenDialog(for: snap))"),
            view: MetricSnippetView(snapshot: snap)
        )
    }
}

// MARK: - Progress

/// "<app> progress" → speaks percentage + label.
public struct ShowWidgetProgressIntent: AppIntent {
    public static let title: LocalizedStringResource = "Show Widget Progress"
    public static let description = IntentDescription("Reads the first progress-kind slice for a Widget app.")

    @Parameter(title: "App", requestValueDialog: IntentDialog("Which Widget app?"))
    public var app: PublishingAppEntity

    public init() {}
    public init(app: PublishingAppEntity) { self.app = app }

    public static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$app) progress")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let snap = WidgetIntentContext.snapshot(for: app.id, kind: .progress) else {
            return .result(
                dialog: IntentDialog("\(app.displayName) hasn't published progress yet."),
                view: EmptySnippetView(text: "\(app.displayName) hasn't published progress yet.")
            )
        }
        return .result(
            dialog: IntentDialog("\(WidgetIntentContext.spokenDialog(for: snap))"),
            view: ProgressSnippetView(snapshot: snap)
        )
    }
}

// MARK: - Generic slice picker

/// Explicit slice picker; dispatches to the correct snippet view at runtime.
public struct ShowWidgetSliceIntent: AppIntent {
    public static let title: LocalizedStringResource = "Show Widget Slice"
    public static let description = IntentDescription("Show any published Widget slice by picking it directly.")

    @Parameter(title: "Slice", requestValueDialog: IntentDialog("Which slice?"))
    public var slice: SliceEntity

    public init() {}
    public init(slice: SliceEntity) { self.slice = slice }

    public static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$slice)")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let snap = WidgetIntentContext.snapshot(for: slice.bundleId, sliceId: slice.sliceId) else {
            return .result(
                dialog: IntentDialog("That slice isn't available yet."),
                view: EmptySnippetView(text: "That slice isn't available yet.")
            )
        }
        let dialog = IntentDialog("\(WidgetIntentContext.spokenDialog(for: snap))")
        switch snap.kind {
        case .count:    return .result(dialog: dialog, view: CountSnippetView(snapshot: snap))
        case .list:     return .result(dialog: dialog, view: ListSnippetView(snapshot: snap))
        case .status:   return .result(dialog: dialog, view: StatusSnippetView(snapshot: snap))
        case .metric:   return .result(dialog: dialog, view: MetricSnippetView(snapshot: snap))
        case .progress: return .result(dialog: dialog, view: ProgressSnippetView(snapshot: snap))
        }
    }
}

// MARK: - Empty snippet fallback

struct EmptySnippetView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(16)
    }
}
