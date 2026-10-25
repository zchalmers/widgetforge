import Foundation

/// A user-facing "who is this widget for" grouping. Personas are a display and
/// discovery concern only — they are never persisted on `WidgetLayout`. The
/// mapping from a catalog layout to its persona lives here, keyed on the
/// catalog's stable UUIDs (see `DefaultLayoutCatalog`). Any layout id not in the
/// catalog (user-created or AI-authored) resolves to `.custom`.
public enum Persona: String, CaseIterable, Sendable, Equatable {
    case manager, sales, time, wellbeing, exec, culture, general, custom

    public var displayName: String {
        switch self {
        case .manager: return "Manager"
        case .sales: return "Sales"
        case .time: return "Time"
        case .wellbeing: return "Wellbeing"
        case .exec: return "Executive"
        case .culture: return "Culture"
        case .general: return "General"
        case .custom: return "Custom"
        }
    }

    /// SF Symbol used on chips and cards.
    public var symbol: String {
        switch self {
        case .manager: return "briefcase.fill"
        case .sales: return "chart.line.uptrend.xyaxis"
        case .time: return "clock.fill"
        case .wellbeing: return "figure.walk"
        case .exec: return "building.2.fill"
        case .culture: return "gift.fill"
        case .general: return "square.grid.2x2.fill"
        case .custom: return "wand.and.stars"
        }
    }

    /// Reuses the existing accent token palette so no new colors are invented.
    public var accentToken: AccentChoice.Token {
        switch self {
        case .manager: return .violet
        case .sales: return .teal
        case .time: return .amber
        case .wellbeing: return .mint
        case .exec: return .coral
        case .culture: return .violet
        case .general: return .teal
        case .custom: return .mint
        }
    }

    /// Personas shown as Browse sections / chips, in display order. `.custom`
    /// is intentionally excluded — custom layouts only ever appear under "Yours".
    public static let browseOrder: [Persona] = [
        .manager, .sales, .time, .wellbeing, .exec, .culture, .general
    ]
}

public enum LayoutPersona {
    /// Catalog layout id → persona. Built from the catalog's public id() so it
    /// stays in lockstep with `DefaultLayoutCatalog`.
    static let map: [UUID: Persona] = {
        func id(_ f: LayoutFamily, _ n: String) -> UUID { DefaultLayoutCatalog.id(family: f, name: n) }
        return [
            id(.small, "Approvals Command"): .manager,
            id(.small, "Sales Pipeline"): .sales,
            id(.small, "Timesheet Status"): .time,
            id(.small, "Team Away"): .general,
            id(.medium, "Approvals Command"): .manager,
            id(.medium, "Sales Pipeline"): .sales,
            id(.medium, "My Time"): .time,
            id(.medium, "Team Away"): .manager,
            id(.large, "Manager Morning Brief"): .manager,
            id(.large, "Sales Pipeline"): .sales,
            id(.large, "My Time"): .time,
            id(.large, "Wellbeing"): .wellbeing,
            id(.extraLarge, "Exec Command Center"): .exec,
            id(.extraLarge, "Sales War Room"): .sales,
            id(.extraLarge, "My Full Day"): .general,
            id(.xlPortrait, "My Workday"): .time,
            id(.xlPortrait, "Wellness Wellbeing"): .wellbeing,
            id(.xlPortrait, "Recognition Feed"): .culture,
        ]
    }()

    public static func persona(forLayoutId id: UUID) -> Persona {
        map[id] ?? .custom
    }

    public static func isCatalogLayout(_ id: UUID) -> Bool {
        map[id] != nil
    }
}
