#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

public struct WFProgressView: View {
    public let config: ProgressConfig
    public let slice: DataSlice?
    @Environment(\.widgetTheme) private var theme
    public init(config: ProgressConfig, slice: DataSlice?) {
        self.config = config; self.slice = slice
    }

    public var body: some View {
        let (value, label, hasData): (Double, String, Bool) = {
            if case .progress(let v, let l)? = slice?.value { return (v, l, true) }
            return (0, "No signal", false)
        }()
        let baseTint: Color = {
            if case .token(let t) = config.accent { return DesignSystem.color(for: t) }
            return DesignSystem.accent(for: config.binding.bundleId).tint
        }()
        let tint = theme.accent(base: baseTint)
        let track = theme.card.style == .none || theme.card.style == .flat
            ? theme.textTertiary.opacity(0.25) : DesignSystem.Widget.cardFill
        switch config.style {
        case .bar:
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(.caption, design: theme.fontDesign))
                    .foregroundStyle(hasData ? theme.textSecondary : theme.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(track)
                        Capsule().fill(tint)
                            .frame(width: geo.size.width * max(0, min(1, value)))
                    }
                }.frame(height: 6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        case .ring:
            ZStack {
                Circle().stroke(track, lineWidth: 6)
                Circle()
                    .trim(from: 0, to: max(0, min(1, value)))
                    .stroke(tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int((max(0, min(1, value))) * 100))%")
                    .font(.system(.caption, design: theme.fontDesign).weight(.semibold))
                    .foregroundStyle(hasData ? theme.textPrimary : theme.textTertiary)
            }
            .padding(4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
#endif
