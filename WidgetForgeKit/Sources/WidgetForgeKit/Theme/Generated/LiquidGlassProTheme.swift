#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Liquid Glass: deep navy base with soft periwinkle/violet refraction blobs,
    /// ultraThinMaterial glass cards with a subtle white stroke, rounded sans.
    static let liquidGlassPro = WidgetTheme(
        id: "liquid-glass-pro",
        name: "Liquid Glass",
        prefersDark: true,
        background: .blobs(
            base: Color(red: 0.04, green: 0.05, blue: 0.10),
            blobs: [
                .init(color: Color(red: 0.38, green: 0.52, blue: 1.00).opacity(0.30),
                      x: 0.15, y: 0.10, radius: 0.55),
                .init(color: Color(red: 0.55, green: 0.32, blue: 0.90).opacity(0.18),
                      x: 0.82, y: 0.75, radius: 0.48)
            ]
        ),
        card: .init(
            style: .glass,
            fill: Color.white.opacity(0.05),
            stroke: Color.white.opacity(0.13),
            strokeWidth: 0.5,
            cornerRadius: 16,
            shadowRadius: 0
        ),
        fontDesign: .rounded,
        heavyWeight: .bold,
        textPrimary: Color(red: 1.00, green: 1.00, blue: 1.00),
        textSecondary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.60),
        textTertiary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.42),
        accentOverride: Color(red: 0.38, green: 0.62, blue: 1.00),
        statusOK: Color(red: 0.38, green: 0.62, blue: 1.00),
        statusWarning: Color(red: 1.00, green: 0.76, blue: 0.20),
        statusCritical: Color(red: 1.00, green: 0.36, blue: 0.36),
        cellSpacing: 5
    )
}
#endif
