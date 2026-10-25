#if canImport(SwiftUI)
import SwiftUI

/// A visual theme applied over any widget layout. A theme is a *token set*: the
/// renderer and every component read their colors, fonts, card treatment, and
/// canvas background from the active `WidgetTheme` instead of hardcoded values.
/// The layout (which cells, where, bound to what data) is independent — picking
/// a theme repaints the same layout in a new aesthetic.
///
/// Themes are identified by a stable string id persisted on `WidgetLayout`.
/// Purely visual and resolved at render time, so `WidgetTheme` itself is not
/// Codable — only the id is stored.
public struct WidgetTheme: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    /// The appearance this theme is designed for; drives the preview chrome.
    public let prefersDark: Bool

    // MARK: Canvas (behind all cells)
    public let background: Background

    // MARK: Card treatment (per cell)
    public let card: Card

    // MARK: Typography
    public let fontDesign: Font.Design
    /// Extra weight nudge for hero numerals (e.g. brutalist wants heavier).
    public let heavyWeight: Font.Weight

    // MARK: Colors
    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    /// When non-nil, overrides the per-app accent so the theme's own accent wins
    /// (e.g. neon themes force their signature glow color). Nil = keep app accent.
    public let accentOverride: Color?
    public let statusOK: Color
    public let statusWarning: Color
    public let statusCritical: Color

    // MARK: Layout feel
    public let cellSpacing: CGFloat

    public init(id: String, name: String, prefersDark: Bool,
                background: Background, card: Card,
                fontDesign: Font.Design = .default, heavyWeight: Font.Weight = .bold,
                textPrimary: Color, textSecondary: Color, textTertiary: Color,
                accentOverride: Color? = nil,
                statusOK: Color, statusWarning: Color, statusCritical: Color,
                cellSpacing: CGFloat = 4) {
        self.id = id; self.name = name; self.prefersDark = prefersDark
        self.background = background; self.card = card
        self.fontDesign = fontDesign; self.heavyWeight = heavyWeight
        self.textPrimary = textPrimary; self.textSecondary = textSecondary
        self.textTertiary = textTertiary; self.accentOverride = accentOverride
        self.statusOK = statusOK; self.statusWarning = statusWarning
        self.statusCritical = statusCritical; self.cellSpacing = cellSpacing
    }

    public static func == (a: WidgetTheme, b: WidgetTheme) -> Bool { a.id == b.id }

    /// Resolve the effective accent for a component: the theme's override wins
    /// when set, otherwise the component's own choice (token or per-app tint).
    public func accent(base: Color) -> Color {
        accentOverride ?? base
    }

    /// Effective status color honoring the theme.
    public func statusColor(_ status: SliceValue.Status) -> Color {
        switch status {
        case .ok: return statusOK
        case .warning: return statusWarning
        case .critical: return statusCritical
        }
    }

    // MARK: - Canvas background

    public enum Background: Sendable {
        case gradient(top: Color, bottom: Color)
        case diagonalGradient(from: Color, to: Color)
        case solid(Color)
        /// A base color plus soft blurred accent blobs (glass/aurora looks).
        case blobs(base: Color, blobs: [Blob])

        public struct Blob: Sendable {
            public let color: Color
            public let x: CGFloat  // 0...1 relative
            public let y: CGFloat
            public let radius: CGFloat  // 0...1 relative to width
            public init(color: Color, x: CGFloat, y: CGFloat, radius: CGFloat) {
                self.color = color; self.x = x; self.y = y; self.radius = radius
            }
        }
    }

    // MARK: - Card treatment

    public struct Card: Sendable {
        public enum Style: Sendable {
            case solid          // opaque fill
            case glass          // ultraThinMaterial
            case flat           // no fill, hairline separators only
            case none           // fully transparent, content sits on canvas
        }
        public let style: Style
        public let fill: Color
        public let stroke: Color
        public let strokeWidth: CGFloat
        public let cornerRadius: CGFloat
        public let shadowRadius: CGFloat

        public init(style: Style, fill: Color, stroke: Color, strokeWidth: CGFloat = 0.5,
                    cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 0) {
            self.style = style; self.fill = fill; self.stroke = stroke
            self.strokeWidth = strokeWidth; self.cornerRadius = cornerRadius
            self.shadowRadius = shadowRadius
        }
    }
}
#endif
