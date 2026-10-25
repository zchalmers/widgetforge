#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

public struct AppTileView: View {
    public let config: AppTileConfig
    public let entry: AppRegistry.Entry?
    @Environment(\.widgetTheme) private var theme
    public init(config: AppTileConfig, entry: AppRegistry.Entry?) {
        self.config = config; self.entry = entry
    }

    public var body: some View {
        let accent = DesignSystem.accent(for: config.bundleId)
        VStack(spacing: 4) {
            Image(systemName: accent.symbol)
                .font(.system(.title2, design: theme.fontDesign))
                .foregroundStyle(theme.accent(base: accent.tint))
            Text(entry?.displayName ?? config.bundleId)
                .font(.system(.caption, design: theme.fontDesign))
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#endif
