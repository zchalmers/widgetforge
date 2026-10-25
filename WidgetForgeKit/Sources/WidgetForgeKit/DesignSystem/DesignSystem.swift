#if canImport(SwiftUI)
import SwiftUI
import UIKit
import ThemeKitThemeManager

/// Design tokens sourced from the Widget ThemeKit theme (`ThemeKitThemeManager`).
///
/// Two surfaces, two rules:
/// - **App UI** (top-level tokens) uses adaptive ThemeKit colors that flip with
///   the system light/dark appearance. This is what makes the app read as a
///   genuine Widget app.
/// - **Widget** (`DesignSystem.Widget`) sits on a fixed dark gradient container
///   that does not track system appearance, so its foreground tokens are pinned
///   to the dark variant via `background: .darkConstant`. Letting those go
///   adaptive would paint dark text on the dark gradient in light mode.
public enum DesignSystem {
    // MARK: - App palette (adaptive)
    public static var textPrimary: Color { Color.preferredColor(.primaryLabel) }
    public static var textSecondary: Color { Color.preferredColor(.secondaryLabel) }
    public static var textTertiary: Color { Color.preferredColor(.tertiaryLabel) }
    public static var divider: Color { Color.preferredColor(.separator) }
    public static var cardFill: Color { Color.preferredColor(.tertiaryFill) }
    public static var cardStroke: Color { Color.preferredColor(.separatorOpaque) }
    public static var suiteAccent: Color { Color.preferredColor(.tintColor) }

    // MARK: - Status (adaptive, ThemeKit semantic)
    public static var statusOK: Color { Color.preferredColor(.positiveLabel) }
    public static var statusWarning: Color { Color.preferredColor(.criticalLabel) }
    public static var statusCritical: Color { Color.preferredColor(.negativeLabel) }
    public static var emptyStateTint: Color { Color.preferredColor(.positiveLabel) }
    public static var errorStateTint: Color { Color.preferredColor(.negativeLabel) }

    // MARK: - Widget palette (pinned dark — fixed dark container)
    public enum Widget {
        public static var textPrimary: Color { Color.preferredColor(.primaryLabel, background: .darkConstant) }
        public static var textSecondary: Color { Color.preferredColor(.secondaryLabel, background: .darkConstant) }
        public static var textTertiary: Color { Color.preferredColor(.tertiaryLabel, background: .darkConstant) }
        public static var cardFill: Color { Color.preferredColor(.tertiaryFill, background: .darkConstant) }
        public static var cardStroke: Color { Color.preferredColor(.separatorOpaque, background: .darkConstant) }
        public static var statusOK: Color { Color.preferredColor(.positiveLabel, background: .darkConstant) }
        public static var statusWarning: Color { Color.preferredColor(.criticalLabel, background: .darkConstant) }
        public static var statusCritical: Color { Color.preferredColor(.negativeLabel, background: .darkConstant) }
        public static var emptyStateTint: Color { Color.preferredColor(.positiveLabel, background: .darkConstant) }
        public static var errorStateTint: Color { Color.preferredColor(.negativeLabel, background: .darkConstant) }

        // The widget's container gradient is a deliberate branded dark surface,
        // not a system-adaptive background — keep it fixed.
        public static let backgroundTop = Color(red: 0.12, green: 0.14, blue: 0.20)
        public static let backgroundBottom = Color(red: 0.05, green: 0.06, blue: 0.10)
    }

    // MARK: - App accent
    public struct AppAccent: Sendable {
        public let tint: Color
        public let symbol: String
        public init(tint: Color, symbol: String) {
            self.tint = tint; self.symbol = symbol
        }
    }

    public static let defaultAccent = AppAccent(
        tint: Color(red: 0.55, green: 0.60, blue: 0.70),
        symbol: "tray.circle.fill"
    )

    public static let appAccents: [String: AppAccent] = [
        "com.example.it.inbox": AppAccent(
            tint: Color(red: 0.98, green: 0.72, blue: 0.20),
            symbol: "checkmark.seal.fill"
        ),
        "com.example.it.inbox.internal": AppAccent(
            tint: Color(red: 0.98, green: 0.72, blue: 0.20),
            symbol: "checkmark.seal.fill"
        ),
        "com.example.Dashboard": AppAccent(
            tint: Color(red: 0.24, green: 0.80, blue: 0.72),
            symbol: "briefcase.fill"
        ),
        "com.example.Dashboard.internal": AppAccent(
            tint: Color(red: 0.24, green: 0.80, blue: 0.72),
            symbol: "briefcase.fill"
        ),
        "com.example.DealApproval": AppAccent(
            tint: Color(red: 0.60, green: 0.44, blue: 0.98),
            symbol: "signature"
        ),
        "com.example.DealApproval.dev": AppAccent(
            tint: Color(red: 0.60, green: 0.44, blue: 0.98),
            symbol: "signature"
        ),
        "com.example.example.fitwidget": AppAccent(
            tint: Color(red: 0.29, green: 0.81, blue: 0.42),
            symbol: "figure.walk"
        ),
        "com.example.example.fitwidget.internal": AppAccent(
            tint: Color(red: 0.29, green: 0.81, blue: 0.42),
            symbol: "figure.walk"
        ),
        "com.example.example.fitwidget.internals": AppAccent(
            tint: Color(red: 0.29, green: 0.81, blue: 0.42),
            symbol: "figure.walk"
        ),
        "com.example.Time Tracker.internal": AppAccent(
            tint: Color(red: 0.12, green: 0.70, blue: 0.65),
            symbol: "clock.badge.checkmark.fill"
        ),
        "com.example.Time Tracker.internal.dev": AppAccent(
            tint: Color(red: 0.12, green: 0.70, blue: 0.65),
            symbol: "clock.badge.checkmark.fill"
        ),
        "com.example.example.Milestones": AppAccent(
            tint: Color(red: 0.91, green: 0.21, blue: 0.56),
            symbol: "gift.fill"
        ),
        "com.example.example.Milestones.dev": AppAccent(
            tint: Color(red: 0.91, green: 0.21, blue: 0.56),
            symbol: "gift.fill"
        ),
        "com.example.timeoff": AppAccent(
            tint: Color(red: 0.02, green: 0.62, blue: 0.60),
            symbol: "calendar.badge.plus"
        ),
        "com.example.meps.timeoff.GIT.internal": AppAccent(
            tint: Color(red: 0.02, green: 0.62, blue: 0.60),
            symbol: "calendar.badge.plus"
        )
    ]

    public static func accent(for bundleId: String) -> AppAccent {
        appAccents[bundleId] ?? defaultAccent
    }

    /// The real app icon (from the module's AppIcons.xcassets) for a registered
    /// app, or nil if none ships for that asset name. Callers fall back to the
    /// app's SF Symbol accent when this is nil.
    public static func appIcon(named assetName: String?) -> Image? {
        guard let assetName, !assetName.isEmpty,
              UIImage(named: assetName, in: .module, with: nil) != nil else { return nil }
        return Image(assetName, bundle: .module)
    }

    // NOTE: no @unknown default - adding an AccentChoice.Token case must update this switch.
    public static func color(for token: AccentChoice.Token) -> Color {
        switch token {
        case .amber: return Color(red: 0.98, green: 0.72, blue: 0.20)
        case .teal: return Color(red: 0.24, green: 0.80, blue: 0.72)
        case .violet: return Color(red: 0.60, green: 0.44, blue: 0.98)
        case .mint: return Color(red: 0.36, green: 0.82, blue: 0.55)
        case .coral: return Color(red: 0.96, green: 0.42, blue: 0.42)
        }
    }

    // MARK: - Chip styles for the Apps tab
    public struct ChipStyle: Sendable {
        public let fill: Color
        public let stroke: Color
        public let text: Color
        public let symbol: String
        public init(fill: Color, stroke: Color, text: Color, symbol: String) {
            self.fill = fill; self.stroke = stroke; self.text = text; self.symbol = symbol
        }
    }

    public static func chipStyle(for status: AppAvailability.Status) -> ChipStyle {
        switch status {
        case .ready:
            return ChipStyle(
                fill: statusOK.opacity(0.16),
                stroke: statusOK.opacity(0.60),
                text: textPrimary,
                symbol: "checkmark.circle.fill"
            )
        case .installedNotPublishing:
            return ChipStyle(
                fill: statusWarning.opacity(0.16),
                stroke: statusWarning.opacity(0.60),
                text: textPrimary,
                symbol: "questionmark.circle.fill"
            )
        case .notInstalled:
            return ChipStyle(
                fill: cardFill,
                stroke: cardStroke,
                text: textTertiary,
                symbol: "arrow.down.circle"
            )
        case .stale:
            return ChipStyle(
                fill: statusWarning.opacity(0.10),
                stroke: statusWarning.opacity(0.35),
                text: textSecondary,
                symbol: "clock.badge.exclamationmark"
            )
        }
    }

    public static func color(fromHex hex: String) -> Color {
        var s = hex
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return textPrimary }
        let r = Double((v >> 16) & 0xFF) / 255.0
        let g = Double((v >> 8) & 0xFF) / 255.0
        let b = Double(v & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}
#endif
