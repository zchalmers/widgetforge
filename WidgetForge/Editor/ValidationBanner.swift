import SwiftUI
import WidgetForgeKit
import ThemeKitThemeManager

/// Green banner when the current draft is validator-clean; red banner naming
/// the specific problem otherwise. Copy is written for end users, not
/// engineers — no error case names in the visible text.
struct ValidationBanner: View {
    let error: WidgetForgeError?

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.themeKit(forTextStyle: .title3))
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(headline)
                    .font(.themeKit(forTextStyle: .callout, weight: .semibold))
                    .foregroundStyle(DesignSystem.textPrimary)
                if let detail {
                    Text(detail)
                        .font(.themeKit(forTextStyle: .caption1))
                        .foregroundStyle(DesignSystem.textSecondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.5), lineWidth: 1)
        )
    }

    private var symbol: String {
        error == nil ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
    }

    private var tint: Color {
        error == nil ? DesignSystem.statusOK : DesignSystem.statusCritical
    }

    private var headline: String {
        switch error {
        case nil: return "Ready to save"
        case .cellOverlap: return "Two cells are overlapping"
        case .cellOutOfBounds: return "A cell is outside the grid"
        default: return "Layout is not valid"
        }
    }

    private var detail: String? {
        switch error {
        case nil: return "Tap Save to update the widget."
        case .cellOverlap: return "Move or resize a cell so it does not sit on top of another."
        case .cellOutOfBounds: return "A cell extends past the widget's edges. Move or shrink it."
        default: return nil
        }
    }
}
