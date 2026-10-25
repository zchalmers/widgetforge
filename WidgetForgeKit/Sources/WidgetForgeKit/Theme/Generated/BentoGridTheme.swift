#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Bento: near-black base with per-tile tinted modules (deep teal + deep violet),
    /// tight 6 pt gutters that expose the dark canvas as implicit grid lines, rounded sans.
    static let bentoGrid = WidgetTheme(
        id: "bento-grid",
        name: "Bento",
        prefersDark: true,
        background: .solid(Color(red: 0.07, green: 0.07, blue: 0.09)),
        card: .init(
            style: .solid,
            fill: Color(red: 0.05, green: 0.18, blue: 0.18),
            stroke: .clear,
            strokeWidth: 0,
            cornerRadius: 14
        ),
        fontDesign: .rounded,
        heavyWeight: .bold,
        textPrimary: Color(red: 1.00, green: 1.00, blue: 1.00),
        textSecondary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.55),
        textTertiary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.28),
        accentOverride: Color(red: 0.20, green: 0.80, blue: 0.72),
        statusOK: Color(red: 0.20, green: 0.80, blue: 0.45),
        statusWarning: Color(red: 0.95, green: 0.65, blue: 0.10),
        statusCritical: Color(red: 0.95, green: 0.30, blue: 0.30),
        cellSpacing: 6
    )
}
#endif
