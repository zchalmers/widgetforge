#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

public struct CountView: View {
    public let config: CountConfig
    public let slice: DataSlice?
    @Environment(\.widgetTheme) private var theme
    public init(config: CountConfig, slice: DataSlice?) {
        self.config = config; self.slice = slice
    }

    public var body: some View {
        let (value, hasData): (Int, Bool) = {
            if case .count(let n)? = slice?.value { return (n, true) }
            return (0, false)
        }()
        VStack(alignment: .leading, spacing: 2) {
            Text(hasData ? WidgetNumberFormat.abbreviate(value) : "–")
                .font(.system(size: 36, weight: theme.heavyWeight, design: theme.fontDesign))
                .foregroundStyle(hasData ? theme.textPrimary : theme.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            if let caption = config.caption {
                Text(caption)
                    .font(.system(.caption, design: theme.fontDesign))
                    .foregroundStyle(theme.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
#endif
