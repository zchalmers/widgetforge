#if canImport(SwiftUI)
import SwiftUI
import ThemeKitThemeManager

public struct ListView: View {
    public let config: ListConfig
    public let slice: DataSlice?
    @Environment(\.widgetTheme) private var theme
    public init(config: ListConfig, slice: DataSlice?) {
        self.config = config; self.slice = slice
    }

    public var body: some View {
        let items: [SliceValue.ListItem] = {
            if case .list(let xs)? = slice?.value {
                return Array(xs.prefix(max(0, config.maxRows)))
            }
            return []
        }()
        VStack(alignment: .leading, spacing: 4) {
            if items.isEmpty {
                Text("No items")
                    .font(.system(.caption, design: theme.fontDesign))
                    .foregroundStyle(theme.textTertiary)
            } else {
                ForEach(items) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(theme.textTertiary)
                            .frame(width: 4, height: 4)
                        Text(item.title)
                            .font(.system(.footnote, design: theme.fontDesign))
                            .foregroundStyle(theme.textPrimary)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
#endif
