import SwiftUI

@MainActor
struct TypographicPosterConcept: WidgetConcept {
    static let id = "typographic-poster"
    static let title = "Typographic Poster"
    static let blurb = "Swiss editorial poster: hero metric bleeds the right edge, extreme weight contrast, rotated stamp, hairline grid."
    static let preferredScheme: ColorScheme = .light

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        let w = family.size.width
        let h = family.size.height
        let isLarge = family == .large
        let heroSize: CGFloat = isLarge ? 196 : 148
        let ink = Color(white: 0.06)
        let paper = Color(red: 0.97, green: 0.95, blue: 0.90)

        return AnyView(
            ZStack(alignment: .topLeading) {

                // 1. Warm paper base
                paper

                // 2. Hairline grid — horizontal dominant, faint verticals
                Canvas { gc, size in
                    let hStep: CGFloat = isLarge ? 24 : 17
                    let vStep: CGFloat = isLarge ? 40 : 28
                    for row in stride(from: hStep, to: size.height, by: hStep) {
                        var p = Path()
                        p.move(to: CGPoint(x: 0, y: row))
                        p.addLine(to: CGPoint(x: size.width, y: row))
                        gc.stroke(p, with: .color(.init(white: 0, opacity: 0.07)), lineWidth: 0.5)
                    }
                    for col in stride(from: vStep, to: size.width, by: vStep) {
                        var p = Path()
                        p.move(to: CGPoint(x: col, y: 0))
                        p.addLine(to: CGPoint(x: col, y: size.height))
                        gc.stroke(p, with: .color(.init(white: 0, opacity: 0.035)), lineWidth: 0.5)
                    }
                }
                .frame(width: w, height: h)

                // 3. Tinted accent slab behind the bleed zone — multiply gives ink-on-paper feel
                ctx.accent.opacity(0.12)
                    .frame(width: w * 0.52, height: isLarge ? heroSize * 0.68 : heroSize * 0.62)
                    .blendMode(.multiply)
                    .offset(x: w * 0.48, y: isLarge ? h * 0.20 : h * 0.12)

                // 4. Left column rule
                ctx.accent.opacity(0.50)
                    .frame(width: 2, height: h * 0.6)
                    .offset(x: 32, y: h * 0.2)

                // 5. App name — ultra-small all-caps, high tracking
                Text(ctx.appName.uppercased())
                    .font(.system(size: 7.5, design: .default).weight(.medium))
                    .foregroundStyle(ink.opacity(0.38))
                    .tracking(3.8)
                    .offset(x: 40, y: 14)

                // 6. Thin rule below app name
                Rectangle()
                    .fill(ink.opacity(0.11))
                    .frame(width: 60, height: 0.5)
                    .offset(x: 40, y: 29)

                // 7. Metric unit — lightweight, small, above / left of the hero
                Text(ctx.metricUnit)
                    .font(.system(size: isLarge ? 17 : 13, design: .rounded).weight(.thin))
                    .foregroundStyle(ctx.accent)
                    .tracking(1.2)
                    .offset(x: 40, y: isLarge ? h * 0.22 : h * 0.14)

                // 8. Hero metric — black weight, positioned so it bleeds the right edge
                Text(ctx.metricValue)
                    .font(.system(size: heroSize, design: .rounded).weight(.black))
                    .monospacedDigit()
                    .foregroundStyle(ink)
                    .tracking(-4)
                    .lineLimit(1)
                    .fixedSize()
                    .offset(x: isLarge ? 96 : 68, y: isLarge ? h * 0.26 : h * 0.18)

                // 9. Trend + caption row — bottom-left anchor
                HStack(spacing: 5) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 9, design: .default).weight(.bold))
                        .foregroundStyle(ctx.accent)
                    Text(ctx.metricCaption)
                        .font(.system(size: 8, design: .default).weight(.regular))
                        .foregroundStyle(ink.opacity(0.50))
                        .tracking(0.4)
                        .lineLimit(1)
                }
                .offset(x: 40, y: isLarge ? h - 78 : h - 28)

                // 10. Rotated caption stamp — right-edge, reads bottom-to-top
                Text(ctx.progressLabel.uppercased())
                    .font(.system(size: 6.5, design: .monospaced).weight(.bold))
                    .foregroundStyle(ctx.accent.opacity(0.55))
                    .tracking(2.5)
                    .rotationEffect(.degrees(-90))
                    .offset(x: w - 16, y: isLarge ? h * 0.50 : h * 0.36)

                // 11. Large-only composition extras
                if isLarge {

                    // Ghost count numeral — ultra-light, overlapping top-right
                    Text("\(ctx.countValue)")
                        .font(.system(size: 76, design: .rounded).weight(.ultraLight))
                        .monospacedDigit()
                        .foregroundStyle(ink.opacity(0.09))
                        .offset(x: w - 86, y: 12)

                    Text(ctx.countCaption.uppercased())
                        .font(.system(size: 6.5, design: .default).weight(.semibold))
                        .foregroundStyle(ink.opacity(0.28))
                        .tracking(2.0)
                        .offset(x: w - 86, y: 92)

                    // Accent secondary label — high contrast, light weight
                    Text(ctx.listTitle.uppercased())
                        .font(.system(size: 8.5, design: .default).weight(.light))
                        .foregroundStyle(ctx.accentSecondary.opacity(0.75))
                        .tracking(1.8)
                        .offset(x: 40, y: h - 118)

                    // Progress bar — thin ruled line, accent fill
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(ink.opacity(0.08))
                            .frame(height: 1)
                        Rectangle()
                            .fill(ctx.accent)
                            .frame(width: (w - 80) * min(ctx.progress, 1.0), height: 2)
                            .offset(y: -0.5)
                    }
                    .frame(width: w - 80)
                    .offset(x: 40, y: h - 104)

                    Text(String(format: "%.0f%% \u{2014} \(ctx.progressLabel.uppercased())", ctx.progress * 100))
                        .font(.system(size: 6.5, design: .monospaced).weight(.medium))
                        .foregroundStyle(ctx.accent.opacity(0.65))
                        .tracking(1.2)
                        .offset(x: 40, y: h - 96)

                    // Items list — tight rows
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(ctx.items.prefix(3))) { item in
                            HStack(spacing: 0) {
                                Text(item.title)
                                    .font(.system(size: 8.5, design: .default).weight(.semibold))
                                    .foregroundStyle(ink.opacity(0.72))
                                    .lineLimit(1)
                                Spacer(minLength: 8)
                                Text(item.subtitle)
                                    .font(.system(size: 8.5, design: .monospaced).weight(.regular))
                                    .foregroundStyle(ctx.accentSecondary.opacity(0.80))
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 4.5)
                            .overlay(alignment: .bottom) {
                                Rectangle().fill(ink.opacity(0.07)).frame(height: 0.5)
                            }
                        }
                    }
                    .frame(width: w - 80)
                    .offset(x: 40, y: h - 72)

                    // Status + updated footer
                    HStack(spacing: 5) {
                        Circle()
                            .fill(ctx.accent)
                            .frame(width: 4, height: 4)
                        Text(ctx.statusText.uppercased())
                            .font(.system(size: 6.5, design: .default).weight(.medium))
                            .foregroundStyle(ink.opacity(0.32))
                            .tracking(1.5)
                        Spacer(minLength: 0)
                        Text(ctx.updatedText)
                            .font(.system(size: 6.5, design: .monospaced).weight(.regular))
                            .foregroundStyle(ink.opacity(0.22))
                    }
                    .frame(width: w - 80)
                    .offset(x: 40, y: h - 13)
                }
            }
            .frame(width: w, height: h)
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }
}
