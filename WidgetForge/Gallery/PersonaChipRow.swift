import SwiftUI
import WidgetForgeKit
import ThemeKitThemeManager

/// Horizontal selectable persona filter. `nil` selection means "All".
struct PersonaChipRow: View {
    @Binding var selection: Persona?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", symbol: "square.grid.2x2", tint: DesignSystem.suiteAccent, isSelected: selection == nil) {
                    selection = nil
                }
                ForEach(Persona.browseOrder, id: \.self) { persona in
                    chip(
                        title: persona.displayName,
                        symbol: persona.symbol,
                        tint: DesignSystem.color(for: persona.accentToken),
                        isSelected: selection == persona
                    ) {
                        selection = (selection == persona) ? nil : persona
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func chip(title: String, symbol: String, tint: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.themeKit(forTextStyle: .footnote, weight: .semibold))
                Text(title)
                    .font(.themeKit(forTextStyle: .subheadline, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? tint : Color.preferredColor(.primaryLabel))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(isSelected ? tint.opacity(0.16) : Color.preferredColor(.tertiaryFill))
            )
            .overlay(
                Capsule().stroke(isSelected ? tint.opacity(0.6) : Color.preferredColor(.separatorOpaque), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
