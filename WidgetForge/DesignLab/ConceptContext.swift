import SwiftUI

/// Input model handed to every design-lab widget concept. Carries a full,
/// realistic spread of data (headline metric, count, status, progress, list)
/// so any aesthetic — editorial single-number, bento grid, data-viz, glass —
/// has enough to render a believable widget. Throwaway: design exploration only.
struct ConceptContext {
    var appName: String
    var accent: Color
    var accentSecondary: Color

    // Headline metric (e.g. pipeline value).
    var metricValue: String
    var metricUnit: String
    var metricCaption: String
    var trend: Trend

    // A count (e.g. pending approvals).
    var countValue: Int
    var countCaption: String

    // Status chip.
    var statusLevel: StatusLevel
    var statusText: String

    // Progress 0...1.
    var progress: Double
    var progressLabel: String

    // A short list.
    var listTitle: String
    var items: [Item]

    // Timestamp shown by some designs.
    var updatedText: String

    struct Item: Identifiable {
        let id = UUID()
        var title: String
        var subtitle: String
    }
    enum Trend { case up, down, flat
        var symbol: String { self == .up ? "arrow.up.right" : self == .down ? "arrow.down.right" : "arrow.right" }
    }
    enum StatusLevel { case ok, warning, critical
        var label: String { self == .ok ? "On track" : self == .warning ? "Attention" : "Critical" }
    }

    /// The single canonical sample every concept renders, so the 20+ screenshots
    /// are directly comparable (only the design differs, never the data).
    static let sample = ConceptContext(
        appName: "Pipeline",
        accent: Color(red: 0.24, green: 0.80, blue: 0.72),
        accentSecondary: Color(red: 0.56, green: 0.44, blue: 1.0),
        metricValue: "4.2",
        metricUnit: "M€",
        metricCaption: "Pipeline value",
        trend: .up,
        countValue: 7,
        countCaption: "Deals need action",
        statusLevel: .warning,
        statusText: "7 need reaffirmation",
        progress: 0.62,
        progressLabel: "31 / 50 up to date",
        listTitle: "Top action deals",
        items: [
            .init(title: "Volkswagen · S/4HANA", subtitle: "1.4M€"),
            .init(title: "Siemens · Cloud renewal", subtitle: "820K€"),
            .init(title: "Allianz · Analytics", subtitle: "610K€"),
            .init(title: "BMW · Ariba", subtitle: "540K€"),
        ],
        updatedText: "Updated 2m ago"
    )
}

/// Widget canvas sizes for the design lab (points), matching the app's editor
/// preview proportions.
enum ConceptFamily: String, CaseIterable {
    case medium, large
    var size: CGSize {
        switch self {
        case .medium: return CGSize(width: 360, height: 170)
        case .large: return CGSize(width: 360, height: 376)
        }
    }
    /// System widget corner radius is ~22pt; concentric children should inset from this.
    var cornerRadius: CGFloat { 24 }
}
