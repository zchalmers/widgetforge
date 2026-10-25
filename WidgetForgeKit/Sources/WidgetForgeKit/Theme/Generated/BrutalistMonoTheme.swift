#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Brutalist: stark white canvas, heavy black monospaced type, hard-rectangle
    /// cards (zero radius), thick grid-rule dividers, per-app accent block, dark
    /// legible status signals — Swiss brutalism meets the declassified data panel.
    static let brutalistMono = WidgetTheme(
        id: "brutalist-mono",
        name: "Brutalist",
        prefersDark: false,
        background: .solid(Color(red: 1.00, green: 1.00, blue: 1.00)),
        card: .init(style: .flat,
                    fill: .clear,
                    stroke: Color(red: 0.00, green: 0.00, blue: 0.00).opacity(0.14),
                    strokeWidth: 1,
                    cornerRadius: 0),
        fontDesign: .monospaced,
        heavyWeight: .black,
        textPrimary: Color(red: 0.00, green: 0.00, blue: 0.00),
        textSecondary: Color(red: 0.00, green: 0.00, blue: 0.00).opacity(0.50),
        textTertiary: Color(red: 0.00, green: 0.00, blue: 0.00).opacity(0.26),
        accentOverride: nil,
        statusOK: Color(red: 0.12, green: 0.52, blue: 0.22),
        statusWarning: Color(red: 0.72, green: 0.46, blue: 0.04),
        statusCritical: Color(red: 0.78, green: 0.10, blue: 0.10),
        cellSpacing: 4
    )
}
#endif
