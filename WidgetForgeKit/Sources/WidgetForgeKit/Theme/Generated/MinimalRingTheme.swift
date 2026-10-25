#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Minimal Ring: near-black canvas, thin hero percentage, content whispered at the
    /// periphery — no card fills, only hairline separators. Accent from app tint.
    static let minimalRing = WidgetTheme(
        id: "minimal-ring",
        name: "Minimal",
        prefersDark: true,
        background: .solid(Color(red: 0.07, green: 0.07, blue: 0.09)),
        card: .init(
            style: .flat,
            fill: .clear,
            stroke: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.05),
            strokeWidth: 0.5,
            cornerRadius: 12
        ),
        fontDesign: .rounded,
        heavyWeight: .thin,
        textPrimary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.88),
        textSecondary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.50),
        textTertiary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.16),
        accentOverride: nil,
        statusOK: Color(red: 0.28, green: 0.88, blue: 0.52),
        statusWarning: Color(red: 0.95, green: 0.75, blue: 0.22),
        statusCritical: Color(red: 0.95, green: 0.32, blue: 0.32),
        cellSpacing: 4
    )
}
#endif
