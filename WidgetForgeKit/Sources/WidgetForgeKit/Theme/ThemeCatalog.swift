#if canImport(SwiftUI)
import SwiftUI

/// The catalog of user-selectable widget themes. `all` is the ordered list the
/// theme picker shows; `theme(id:)` resolves a stored id back to a theme
/// (falling back to classic if an id is unknown, e.g. an old layout).
///
/// Each theme translates one of the design-lab concepts into the token
/// vocabulary of `WidgetTheme`. Structural/generative concepts that cannot be
/// expressed as tokens are intentionally not represented here.
public enum ThemeCatalog {
    public static let all: [WidgetTheme] = [
        .classicDark,
        .liquidGlassPro,
        .glassFrost,
        .auroraGradient,
        .holographic,
        .warmSunset,
        .neonCyber,
        .terminalRetro,
        .boldDataViz,
        .bentoGrid,
        .minimalRing,
        .paperMinimal,
        .swissInternational,
        .newspaper,
        .brutalistMono,
    ]

    public static func theme(id: String?) -> WidgetTheme {
        guard let id else { return .classicDark }
        return all.first { $0.id == id } ?? .classicDark
    }
}
#endif
