#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Glass Frost: near-black midnight base with frosted ultraThinMaterial cards,
    /// violet and cyan blurred blobs bleeding through the glass, white borders.
    static let glassFrost = WidgetTheme(
        id: "glass-frost",
        name: "Glass Frost",
        prefersDark: true,
        background: .blobs(
            base: Color(red: 0.05, green: 0.05, blue: 0.11),
            blobs: [
                .init(color: Color(red: 0.45, green: 0.22, blue: 0.88).opacity(0.65),
                      x: 0.34, y: 0.36, radius: 0.36),
                .init(color: Color(red: 0.08, green: 0.68, blue: 0.92).opacity(0.55),
                      x: 0.78, y: 0.82, radius: 0.31)
            ]
        ),
        card: .init(
            style: .glass,
            fill: Color.white.opacity(0.06),
            stroke: Color.white.opacity(0.18),
            strokeWidth: 1,
            cornerRadius: 16,
            shadowRadius: 12
        ),
        fontDesign: .rounded,
        heavyWeight: .bold,
        textPrimary:   Color(red: 1.00, green: 1.00, blue: 1.00),
        textSecondary: Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.58),
        textTertiary:  Color(red: 1.00, green: 1.00, blue: 1.00).opacity(0.38),
        accentOverride: Color(red: 0.42, green: 0.72, blue: 1.00),
        statusOK:       Color(red: 0.18, green: 0.86, blue: 0.40),
        statusWarning:  Color(red: 1.00, green: 0.72, blue: 0.00),
        statusCritical: Color(red: 1.00, green: 0.28, blue: 0.28),
        cellSpacing: 10
    )
}
#endif
