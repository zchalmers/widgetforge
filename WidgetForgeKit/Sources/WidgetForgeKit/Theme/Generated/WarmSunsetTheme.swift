#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Warm Sunset: vertical orange-to-deep-night gradient, glass cards,
    /// cream text, rounded font, glowAmber accent. Golden-hour mood.
    static let warmSunset = WidgetTheme(
        id: "warm-sunset",
        name: "Warm Sunset",
        prefersDark: true,
        background: .gradient(
            top: Color(red: 1.00, green: 0.52, blue: 0.18),
            bottom: Color(red: 0.12, green: 0.05, blue: 0.26)
        ),
        card: .init(
            style: .glass,
            fill: Color(red: 1.00, green: 0.94, blue: 0.82).opacity(0.07),
            stroke: Color(red: 1.00, green: 0.94, blue: 0.82).opacity(0.15),
            strokeWidth: 0.5,
            cornerRadius: 14
        ),
        fontDesign: .rounded,
        heavyWeight: .heavy,
        textPrimary:   Color(red: 1.00, green: 0.94, blue: 0.82),
        textSecondary: Color(red: 1.00, green: 0.94, blue: 0.82).opacity(0.75),
        textTertiary:  Color(red: 1.00, green: 0.94, blue: 0.82).opacity(0.45),
        accentOverride: Color(red: 1.00, green: 0.66, blue: 0.22),
        statusOK:       Color(red: 1.00, green: 0.52, blue: 0.18),
        statusWarning:  Color(red: 0.98, green: 0.30, blue: 0.50),
        statusCritical: Color(red: 1.00, green: 0.28, blue: 0.28),
        cellSpacing: 5
    )
}
#endif
