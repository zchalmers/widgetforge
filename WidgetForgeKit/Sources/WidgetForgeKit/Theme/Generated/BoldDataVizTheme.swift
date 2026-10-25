#if canImport(SwiftUI)
import SwiftUI

extension WidgetTheme {
    /// Bold Data: deep-navy analytical canvas with electric-azure accent, blobs
    /// replicating the concept's left-center and top-right radial glows, black-
    /// weight hero numerals, monospaced captions, and fully transparent cards so
    /// content sits directly on the dark field.
    static let boldDataViz = WidgetTheme(
        id: "bold-dataviz",
        name: "Bold Data",
        prefersDark: true,
        background: .blobs(
            base: Color(red: 0.055, green: 0.063, blue: 0.092),
            blobs: [
                .init(color: Color(red: 0.20, green: 0.65, blue: 1.00).opacity(0.18),
                      x: 0.02, y: 0.50, radius: 0.58),
                .init(color: Color(red: 0.52, green: 0.25, blue: 1.00).opacity(0.12),
                      x: 0.98, y: 0.03, radius: 0.46),
            ]
        ),
        card: .init(style: .none,
                    fill: .clear,
                    stroke: .clear,
                    strokeWidth: 0,
                    cornerRadius: 10),
        fontDesign: .monospaced,
        heavyWeight: .black,
        textPrimary:   Color(red: 0.95, green: 0.97, blue: 1.00),
        textSecondary: Color(red: 0.72, green: 0.82, blue: 0.95).opacity(0.70),
        textTertiary:  Color(red: 0.60, green: 0.72, blue: 0.90).opacity(0.42),
        accentOverride: Color(red: 0.20, green: 0.65, blue: 1.00),
        statusOK:       Color(red: 0.20, green: 0.85, blue: 0.55),
        statusWarning:  Color(red: 1.00, green: 0.75, blue: 0.20),
        statusCritical: Color(red: 1.00, green: 0.35, blue: 0.35),
        cellSpacing: 5
    )
}
#endif
