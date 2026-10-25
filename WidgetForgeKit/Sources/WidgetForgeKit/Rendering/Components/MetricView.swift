#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

public struct MetricView: View {
    public let config: MetricConfig
    public let slice: DataSlice?
    @Environment(\.widgetTheme) private var theme
    public init(config: MetricConfig, slice: DataSlice?) {
        self.config = config; self.slice = slice
    }

    public var body: some View {
        let (value, unit, trend, hasData): (Double, String?, SliceValue.Trend?, Bool) = {
            if case .metric(let v, let u, let t)? = slice?.value { return (v, u, t, true) }
            return (0, nil, nil, false)
        }()
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(hasData ? WidgetNumberFormat.abbreviate(value) : "–")
                    .font(.system(size: 30, weight: theme.heavyWeight, design: theme.fontDesign))
                    .foregroundStyle(hasData ? theme.textPrimary : theme.textTertiary)
                    .lineLimit(1)
                    .layoutPriority(1)
                if let unit {
                    Text(unit)
                        .font(.system(.caption, design: theme.fontDesign))
                        .foregroundStyle(theme.textSecondary)
                        .lineLimit(1)
                }
                if let trend { trendGlyph(trend) }
            }
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

    @ViewBuilder
    private func trendGlyph(_ trend: SliceValue.Trend) -> some View {
        switch trend {
        case .up: Image(systemName: "arrow.up.right").foregroundStyle(theme.statusOK)
        case .down: Image(systemName: "arrow.down.right").foregroundStyle(theme.statusCritical)
        case .flat: Image(systemName: "arrow.right").foregroundStyle(theme.textSecondary)
        }
    }
}
#endif
