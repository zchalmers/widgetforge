#if canImport(SwiftUI)
import SwiftUI

// Two hand-authored themes spanning the token range (dark neon + light paper),
// used to validate that the WidgetTheme vocabulary is expressive enough before
// the full set is generated. Appended to ThemeCatalog.all.
extension WidgetTheme {
    /// Neon Cyber: near-black violet base, glowing cyan accent, monospace.
    static let neonCyber = WidgetTheme(
        id: "neon-cyber",
        name: "Neon Cyber",
        prefersDark: true,
        background: .diagonalGradient(from: Color(red: 0.05, green: 0.03, blue: 0.12),
                                      to: Color(red: 0.02, green: 0.01, blue: 0.06)),
        card: .init(style: .flat,
                    fill: .clear,
                    stroke: Color(red: 0.05, green: 0.95, blue: 1.00).opacity(0.35),
                    strokeWidth: 1, cornerRadius: 8),
        fontDesign: .monospaced,
        heavyWeight: .heavy,
        textPrimary: Color(red: 0.90, green: 0.98, blue: 1.00),
        textSecondary: Color(red: 0.05, green: 0.95, blue: 1.00).opacity(0.75),
        textTertiary: Color(red: 0.72, green: 0.10, blue: 1.00).opacity(0.70),
        accentOverride: Color(red: 0.05, green: 0.95, blue: 1.00),
        statusOK: Color(red: 0.30, green: 1.00, blue: 0.60),
        statusWarning: Color(red: 1.00, green: 0.80, blue: 0.20),
        statusCritical: Color(red: 1.00, green: 0.07, blue: 0.60),
        cellSpacing: 5
    )

    /// Paper Minimal: warm cream, ink-blue text, terracotta accent, serif.
    static let paperMinimal = WidgetTheme(
        id: "paper-minimal",
        name: "Paper",
        prefersDark: false,
        background: .solid(Color(red: 0.965, green: 0.948, blue: 0.910)),
        card: .init(style: .flat,
                    fill: .clear,
                    stroke: Color(red: 0.148, green: 0.192, blue: 0.318).opacity(0.12),
                    strokeWidth: 0.5, cornerRadius: 10),
        fontDesign: .serif,
        heavyWeight: .semibold,
        textPrimary: Color(red: 0.148, green: 0.192, blue: 0.318),
        textSecondary: Color(red: 0.148, green: 0.192, blue: 0.318).opacity(0.60),
        textTertiary: Color(red: 0.148, green: 0.192, blue: 0.318).opacity(0.35),
        accentOverride: Color(red: 0.688, green: 0.352, blue: 0.258),
        statusOK: Color(red: 0.30, green: 0.55, blue: 0.35),
        statusWarning: Color(red: 0.80, green: 0.55, blue: 0.20),
        statusCritical: Color(red: 0.70, green: 0.30, blue: 0.25),
        cellSpacing: 6
    )
}
#endif
