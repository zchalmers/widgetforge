#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Swiss International: pure white field, near-black ink, smoke secondary,
    /// hairline flat cards (0 radius), Helvetica-like system font, Swiss red for status.
    static let swissInternational = WidgetTheme(
        id: "swiss",
        name: "Swiss",
        prefersDark: false,
        background: .solid(Color(red: 1.00, green: 1.00, blue: 1.00)),
        card: .init(
            style: .flat,
            fill: .clear,
            stroke: Color(red: 0.84, green: 0.84, blue: 0.84),
            strokeWidth: 0.5,
            cornerRadius: 0
        ),
        fontDesign: .default,
        heavyWeight: .bold,
        textPrimary:   Color(red: 0.06, green: 0.06, blue: 0.06),
        textSecondary: Color(red: 0.50, green: 0.50, blue: 0.50),
        textTertiary:  Color(red: 0.50, green: 0.50, blue: 0.50).opacity(0.55),
        accentOverride: nil,
        statusOK:       Color(red: 0.20, green: 0.55, blue: 0.25),
        statusWarning:  Color(red: 0.85, green: 0.55, blue: 0.10),
        statusCritical: Color(red: 0.93, green: 0.07, blue: 0.09),
        cellSpacing: 6
    )
}
#endif
