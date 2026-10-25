#if canImport(SwiftUI)
import SwiftUI

/// Environment plumbing for the active `WidgetTheme`. Components read
/// `@Environment(\.widgetTheme)` instead of hardcoded `DesignSystem.Widget`
/// tokens, so a whole layout repaints when the renderer sets one theme at the
/// top. The default value reproduces the original branded-dark look exactly, so
/// any view that does not set a theme renders identically to before.
public struct WidgetThemeKey: EnvironmentKey {
    public static let defaultValue: WidgetTheme = .classicDark
}

extension EnvironmentValues {
    public var widgetTheme: WidgetTheme {
        get { self[WidgetThemeKey.self] }
        set { self[WidgetThemeKey.self] = newValue }
    }
}

extension View {
    /// Apply a theme to a subtree (renderer, editor canvas, previews).
    public func widgetTheme(_ theme: WidgetTheme) -> some View {
        environment(\.widgetTheme, theme)
    }
}

extension WidgetTheme {
    /// The original look: pinned-dark ThemeKit tokens on the branded dark gradient.
    /// Kept as the default so unthemed rendering is byte-identical to pre-theme.
    public static let classicDark = WidgetTheme(
        id: "classic-dark",
        name: "Classic",
        prefersDark: true,
        background: .gradient(top: DesignSystem.Widget.backgroundTop,
                              bottom: DesignSystem.Widget.backgroundBottom),
        card: .init(style: .solid,
                    fill: DesignSystem.Widget.cardFill,
                    stroke: DesignSystem.Widget.cardStroke,
                    strokeWidth: 0.5, cornerRadius: 12),
        fontDesign: .default,
        heavyWeight: .bold,
        textPrimary: DesignSystem.Widget.textPrimary,
        textSecondary: DesignSystem.Widget.textSecondary,
        textTertiary: DesignSystem.Widget.textTertiary,
        accentOverride: nil,
        statusOK: DesignSystem.Widget.statusOK,
        statusWarning: DesignSystem.Widget.statusWarning,
        statusCritical: DesignSystem.Widget.statusCritical,
        cellSpacing: 4
    )
}
#endif
