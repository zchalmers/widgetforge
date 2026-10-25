#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Aurora: deep-night base with soft teal, violet, green, and cyan aurora-ribbon
    /// blobs rendered over a near-black navy canvas. Rounded type, white-on-dark text,
    /// glowing teal accent.
    static let auroraGradient = WidgetTheme(
        id: "aurora-gradient",
        name: "Aurora",
        prefersDark: true,
        background: .blobs(
            base: Color(red: 0.03, green: 0.05, blue: 0.12),
            blobs: [
                // Soft teal corona — top-left anchor
                .init(color: Color(red: 0.15, green: 0.95, blue: 0.80).opacity(0.55),
                      x: 0.12, y: 0.08, radius: 0.55),
                // Teal diagonal sweep — mid sweep point
                .init(color: Color(red: 0.15, green: 0.95, blue: 0.80).opacity(0.38),
                      x: 0.50, y: 0.32, radius: 0.42),
                // Green horizontal mid-band
                .init(color: Color(red: 0.20, green: 0.90, blue: 0.55).opacity(0.42),
                      x: 0.42, y: 0.44, radius: 0.52),
                // Violet radial bloom — bottom-right
                .init(color: Color(red: 0.55, green: 0.35, blue: 1.00).opacity(0.55),
                      x: 0.82, y: 0.90, radius: 0.65),
                // Cyan streak — top-center
                .init(color: Color(red: 0.10, green: 0.78, blue: 0.98).opacity(0.32),
                      x: 0.45, y: 0.18, radius: 0.36)
            ]
        ),
        card: .init(
            style: .glass,
            fill: .clear,
            stroke: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.13),
            strokeWidth: 0.5,
            cornerRadius: 14,
            shadowRadius: 0
        ),
        fontDesign: .rounded,
        heavyWeight: .bold,
        textPrimary:   Color(red: 1.00, green: 1.00, blue: 1.00),
        textSecondary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.70),
        textTertiary:  Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.38),
        accentOverride: Color(red: 0.15, green: 0.95, blue: 0.80),
        statusOK:       Color(red: 0.20, green: 0.90, blue: 0.55),
        statusWarning:  Color(red: 1.00, green: 0.82, blue: 0.30),
        statusCritical: Color(red: 1.00, green: 0.25, blue: 0.45),
        cellSpacing: 5
    )
}
#endif
