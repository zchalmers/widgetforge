#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

public struct StatusView: View {
    public let config: StatusConfig
    public let slice: DataSlice?
    @Environment(\.widgetTheme) private var theme
    public init(config: StatusConfig, slice: DataSlice?) {
        self.config = config; self.slice = slice
    }

    public var body: some View {
        let (status, text, hasData): (SliceValue.Status, String, Bool) = {
            if case .status(let s, let t)? = slice?.value { return (s, t, true) }
            return (.ok, "No signal", false)
        }()
        HStack(spacing: 8) {
            Circle()
                .fill(hasData ? theme.statusColor(status) : theme.textTertiary)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.system(.callout, design: theme.fontDesign))
                .foregroundStyle(hasData ? theme.textPrimary : theme.textTertiary)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
#endif
