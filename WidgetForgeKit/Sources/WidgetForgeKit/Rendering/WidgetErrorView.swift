#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

public struct WidgetErrorView: View {
    public let kind: WidgetKind
    public let reason: RecoveryReason
    public let layoutId: UUID?

    public init(kind: WidgetKind, reason: RecoveryReason, layoutId: UUID?) {
        self.kind = kind
        self.reason = reason
        self.layoutId = layoutId
    }

    public var recoveryURL: URL {
        DeepLinkBuilder.recover(kind: kind, reason: reason, layoutId: layoutId)
    }

    public var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.themeKit(forTextStyle: .title2))
                .foregroundStyle(tint)
            Text(headline)
                .font(.themeKit(forTextStyle: .callout, weight: .semibold))
                .foregroundStyle(DesignSystem.Widget.textPrimary)
                .multilineTextAlignment(.center)
            Text(subhead)
                .font(.themeKit(forTextStyle: .caption1))
                .foregroundStyle(DesignSystem.Widget.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [DesignSystem.Widget.backgroundTop, DesignSystem.Widget.backgroundBottom],
                           startPoint: .top, endPoint: .bottom)
        )
    }

    private var tint: Color {
        switch reason {
        case .noManifests, .missingSlice, .missingLayout: return DesignSystem.Widget.emptyStateTint
        case .readFailure, .containerUnreadable: return DesignSystem.Widget.errorStateTint
        }
    }

    private var symbol: String {
        switch reason {
        case .noManifests: return "square.stack.3d.up.slash"
        case .missingSlice: return "questionmark.folder"
        case .missingLayout: return "rectangle.dashed"
        case .readFailure: return "exclamationmark.triangle.fill"
        case .containerUnreadable: return "lock.slash"
        }
    }

    private var headline: String {
        switch reason {
        case .noManifests: return "No apps publishing"
        case .missingSlice: return "Data unavailable"
        case .missingLayout: return "Layout missing"
        case .readFailure: return "Couldn't load"
        case .containerUnreadable: return "Shared container blocked"
        }
    }

    private var subhead: String {
        switch reason {
        case .noManifests: return "Open WidgetForge to add an app."
        case .missingSlice: return "The bound slice isn't published yet."
        case .missingLayout: return "Pick a layout in WidgetForge."
        case .readFailure: return "Tap to open WidgetForge."
        case .containerUnreadable: return "Check App Group entitlements."
        }
    }
}
#endif
