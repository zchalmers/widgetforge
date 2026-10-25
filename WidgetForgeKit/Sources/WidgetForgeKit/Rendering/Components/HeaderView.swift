#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

public struct HeaderView: View {
    public let config: HeaderConfig
    @Environment(\.widgetTheme) private var theme
    public init(config: HeaderConfig) { self.config = config }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(config.title)
                .font(.system(.headline, design: theme.fontDesign).weight(.semibold))
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            if let sub = config.subtitle, !sub.isEmpty {
                Text(sub)
                    .font(.system(.caption, design: theme.fontDesign))
                    .foregroundStyle(theme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
#endif
