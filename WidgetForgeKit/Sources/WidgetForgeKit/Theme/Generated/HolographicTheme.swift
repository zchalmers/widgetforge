#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Holographic Foil: near-black blue-violet base with four iridescent spectrum
    /// blobs (violet bottom-left, cyan top-center, magenta top-right, mint mid-right)
    /// mirroring the concept's dual-conic interference pattern. Glass cards with a
    /// white hairline stroke echo the foil's specular edge catch. Pure-white text
    /// hierarchy reads cleanly against the dark canvas.
    static let holographic = WidgetTheme(
        id: "holographic",
        name: "Holographic",
        prefersDark: true,
        background: .blobs(
            base: Color(red: 0.04, green: 0.03, blue: 0.09),
            blobs: [
                // Violet — primary conic origin (bottom-left in concept)
                .init(color: Color(red: 0.55, green: 0.15, blue: 1.00).opacity(0.55),
                      x: 0.12, y: 0.88, radius: 0.62),
                // Cyan — top sweep
                .init(color: Color(red: 0.00, green: 0.85, blue: 1.00).opacity(0.45),
                      x: 0.50, y: 0.08, radius: 0.46),
                // Magenta — counter-conic origin (top-right in concept)
                .init(color: Color(red: 1.00, green: 0.25, blue: 0.75).opacity(0.32),
                      x: 0.88, y: 0.12, radius: 0.42),
                // Mint — mid-right fill
                .init(color: Color(red: 0.00, green: 1.00, blue: 0.72).opacity(0.28),
                      x: 0.85, y: 0.62, radius: 0.38),
            ]
        ),
        card: .init(
            style: .glass,
            fill: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.08),
            stroke: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.18),
            strokeWidth: 1.0,
            cornerRadius: 14
        ),
        fontDesign: .rounded,
        heavyWeight: .bold,
        textPrimary: Color(red: 1.00, green: 1.00, blue: 1.00),
        textSecondary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.65),
        textTertiary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.42),
        accentOverride: Color(red: 0.00, green: 0.85, blue: 1.00),
        statusOK: Color(red: 0.00, green: 1.00, blue: 0.65),
        statusWarning: Color(red: 1.00, green: 0.80, blue: 0.10),
        statusCritical: Color(red: 1.00, green: 0.28, blue: 0.38),
        cellSpacing: 5
    )
}
#endif
