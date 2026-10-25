import SwiftUI
import WidgetForgeKit
import ThemeKitThemeManager

/// A gallery tile: live mini widget preview + title + "Persona · Size".
struct GalleryCard: View {
    let layout: WidgetLayout
    let context: RenderContext
    let onTap: () -> Void

    private var persona: Persona { LayoutPersona.persona(forLayoutId: layout.id) }
    private var tint: Color { DesignSystem.color(for: persona.accentToken) }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                thumbnail

                Text(layout.name)
                    .font(.themeKit(forTextStyle: .subheadline, weight: .semibold))
                    .foregroundStyle(Color.preferredColor(.primaryLabel))
                    .lineLimit(1)

                HStack(spacing: 5) {
                    Circle().fill(tint).frame(width: 7, height: 7)
                    Text("\(persona.displayName) · \(familyLabel)")
                        .font(.themeKit(forTextStyle: .caption1))
                        .foregroundStyle(Color.preferredColor(.secondaryLabel))
                        .lineLimit(1)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.preferredColor(.tertiaryFill)))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.preferredColor(.separatorOpaque), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    /// The widget rendered at its true point-size, then scaled down to fit the
    /// card width. Scaling the whole render (rather than rendering into a tiny
    /// frame) keeps every cell proportional to the real widget, so nothing gets
    /// crushed or truncated in the thumbnail — text just gets smaller.
    private var thumbnail: some View {
        GeometryReader { geo in
            let scale = geo.size.width / nativeSize.width
            LayoutRenderer(layout: layout, context: context)
                .widgetTheme(ThemeCatalog.theme(id: layout.themeId))
                .frame(width: nativeSize.width, height: nativeSize.height)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: geo.size.width, height: nativeSize.height * scale, alignment: .topLeading)
        }
        .aspectRatio(nativeSize.width / nativeSize.height, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .allowsHitTesting(false)
    }

    /// The widget's true aspect at real point-size, derived from its grid so the
    /// mini preview matches the full-size preview's proportions. 88pt per grid
    /// unit approximates a real Home Screen widget cell.
    private var nativeSize: CGSize {
        let unit: CGFloat = 88
        return CGSize(width: CGFloat(layout.family.cols) * unit,
                      height: CGFloat(layout.family.rows) * unit)
    }

    private var familyLabel: String {
        switch layout.family {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .extraLarge: return "XL"
        case .xlPortrait: return "XL Portrait"
        }
    }
}
