#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Terminal: pure-black CRT field with phosphor-green monospace, ASCII card
    /// chrome, amber/red status signals, and tight scanline-era spacing.
    static let terminalRetro = WidgetTheme(
        id: "terminal-retro",
        name: "Terminal",
        prefersDark: true,
        background: .solid(Color(red: 0.03, green: 0.03, blue: 0.03)),
        card: .init(style: .flat,
                    fill: .clear,
                    stroke: Color(red: 0.10, green: 0.90, blue: 0.10).opacity(0.30),
                    strokeWidth: 1,
                    cornerRadius: 4),
        fontDesign: .monospaced,
        heavyWeight: .bold,
        textPrimary: Color(red: 0.10, green: 0.90, blue: 0.10),
        textSecondary: Color(red: 0.10, green: 0.90, blue: 0.10).opacity(0.55),
        textTertiary: Color(red: 0.10, green: 0.90, blue: 0.10).opacity(0.32),
        accentOverride: Color(red: 0.10, green: 0.90, blue: 0.10),
        statusOK: Color(red: 0.10, green: 0.90, blue: 0.10),
        statusWarning: Color(red: 0.95, green: 0.80, blue: 0.05),
        statusCritical: Color(red: 0.95, green: 0.22, blue: 0.12),
        cellSpacing: 4
    )
}
#endif
