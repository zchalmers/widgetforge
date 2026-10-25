import WidgetKit
import SwiftUI
import AppIntents
import WidgetForgeKit
import ThemeKitThemeManager

@main
struct WidgetForgeWidgetsBundle: WidgetBundle {
    init() {
        // The widget runs in its own process; ThemeKit font registration is
        // per-process, so register here as well as in the app delegate.
        Font.registerThemeKitFonts()
    }

    var body: some Widget {
        SmallWidget()
        MediumWidget()
        LargeWidget()
        ExtraLargeWidget()
    }
}

// MARK: - Widget kinds

struct SmallWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WidgetKind.WFSmall.rawValue,
            intent: SelectLayoutIntent.self,
            provider: LayoutTimelineProvider(role: .small)
        ) { entry in
            WidgetRootView(entry: entry, role: .small)
        }
        .configurationDisplayName("Widget Small")
        .description("Configurable Widget status tile.")
        .supportedFamilies([.systemSmall])
        .containerBackgroundRemovable(false)
    }
}

struct MediumWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WidgetKind.WFMedium.rawValue,
            intent: SelectLayoutIntent.self,
            provider: LayoutTimelineProvider(role: .medium)
        ) { entry in
            WidgetRootView(entry: entry, role: .medium)
        }
        .configurationDisplayName("Widget Medium")
        .description("Two-column Widget layout with counts and lists.")
        .supportedFamilies([.systemMedium])
    }
}

struct LargeWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WidgetKind.WFLarge.rawValue,
            intent: SelectLayoutIntent.self,
            provider: LayoutTimelineProvider(role: .large)
        ) { entry in
            WidgetRootView(entry: entry, role: .large)
        }
        .configurationDisplayName("Widget Large")
        .description("Four-by-four Widget dashboard.")
        .supportedFamilies([.systemLarge])
    }
}

struct ExtraLargeWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WidgetKind.WFXL.rawValue,
            intent: SelectLayoutIntent.self,
            provider: LayoutTimelineProvider(role: .extraLarge)
        ) { entry in
            WidgetRootView(entry: entry, role: .extraLarge)
        }
        .configurationDisplayName("Widget XL")
        .description("Extra-large Widget dashboard.")
        .supportedFamilies(supportedFamiliesForXL())
    }

    private func supportedFamiliesForXL() -> [WidgetFamily] {
        // On iPhone the only extra-large canvas is iOS 27's full-page 4×6
        // portrait family; .systemExtraLarge is iPad/macOS-only and never
        // surfaces on iPhone.
        if #available(iOS 27.0, *) { return [.systemExtraLargePortrait] }
        return []
    }
}

enum WidgetRole: String, Sendable {
    case small, medium, large, extraLarge

    var families: [WidgetFamily] {
        switch self {
        case .small: return [.systemSmall]
        case .medium: return [.systemMedium]
        case .large: return [.systemLarge]
        case .extraLarge:
            if #available(iOS 27.0, *) { return [.systemExtraLargePortrait] }
            return []
        }
    }

    var defaultFamily: LayoutFamily {
        switch self {
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .extraLarge: return .extraLarge
        }
    }

    var widgetKind: WidgetKind {
        switch self {
        case .small: return .WFSmall
        case .medium: return .WFMedium
        case .large: return .WFLarge
        case .extraLarge: return .WFXL
        }
    }
}
