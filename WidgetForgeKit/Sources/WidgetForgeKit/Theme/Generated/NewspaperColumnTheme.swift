#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Newspaper: cream newsprint background, near-black ink text, flat hairline
    /// cards, system font with black headline weight — dense editorial column layout.
    static let newspaper = WidgetTheme(
        id: "newspaper",
        name: "Newspaper",
        prefersDark: false,
        background: .solid(Color(red: 0.96, green: 0.93, blue: 0.86)),
        card: .init(style: .flat,
                    fill: .clear,
                    stroke: Color(red: 0.10, green: 0.09, blue: 0.07).opacity(0.20),
                    strokeWidth: 0.75,
                    cornerRadius: 4),
        fontDesign: .default,
        heavyWeight: .black,
        textPrimary:   Color(red: 0.10, green: 0.09, blue: 0.07),
        textSecondary: Color(red: 0.10, green: 0.09, blue: 0.07).opacity(0.62),
        textTertiary:  Color(red: 0.10, green: 0.09, blue: 0.07).opacity(0.38),
        accentOverride: nil,
        statusOK:       Color(red: 0.12, green: 0.50, blue: 0.25),
        statusWarning:  Color(red: 0.74, green: 0.38, blue: 0.04),
        statusCritical: Color(red: 0.68, green: 0.10, blue: 0.10),
        cellSpacing: 4
    )
}
#endif
