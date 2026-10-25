import SwiftUI

// Pop-art halftone: a Canvas dot-matrix whose radii encode the accent/secondary
// gradient across the canvas. Bold metric overprinted in black ink on paper.
@MainActor
struct HalftoneGradientConcept: WidgetConcept {

    static let id               = "halftone-gradient"
    static let title            = "Halftone Gradient"
    static let blurb            = "Pop-art dot-matrix renders the accent gradient as halftone; hero metric inked bold on top."
    static let preferredScheme: ColorScheme = .light

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(root(ctx: ctx, family: family))
    }

    // MARK: - Root

    private func root(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack(alignment: .topLeading) {
            // Off-white paper base
            Color(red: 0.975, green: 0.965, blue: 0.945)

            // Halftone dot field — two interleaved sub-grids, accent vs secondary
            Canvas { gc, size in
                dotMatrix(gc: gc, size: size, ctx: ctx,
                          spacing: family == .large ? 13 : 10)
            }

            // Typographic overprint
            Group {
                if family == .medium {
                    mediumPrint(ctx: ctx)
                } else {
                    largePrint(ctx: ctx)
                }
            }
            .padding(family == .large ? 18 : 16)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Dot matrix

    private func dotMatrix(gc: GraphicsContext, size: CGSize, ctx: ConceptContext, spacing: CGFloat) {
        let cols = Int(size.width  / spacing) + 2
        let rows = Int(size.height / spacing) + 2
        let half = spacing * 0.5

        for row in 0..<rows {
            for col in 0..<cols {
                // Stagger alternate rows for a classic halftone offset
                let xOff: CGFloat = row % 2 == 0 ? 0 : half
                let x = CGFloat(col) * spacing + xOff
                let y = CGFloat(row) * spacing

                let nx = max(0, min(1, x / size.width))
                let ny = max(0, min(1, y / size.height))

                // Accent field: radial peak at top-left
                let dA = sqrt(nx * nx + ny * ny) / sqrt(2)
                let intA = 1.0 - dA

                // Secondary field: radial peak at bottom-right
                let dB = sqrt((1 - nx) * (1 - nx) + (1 - ny) * (1 - ny)) / sqrt(2)
                let intB = 1.0 - dB

                // Pick the locally dominant field so dots carry the gradient split
                let useAccent = intA >= intB
                let intensity = useAccent ? intA : intB
                let color     = useAccent ? ctx.accent : ctx.accentSecondary

                let maxR = spacing * 0.46
                let r    = max(0.6, maxR * pow(intensity, 0.6))

                var dot = Path()
                dot.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
                gc.fill(dot, with: .color(color.opacity(0.80)))
            }
        }
    }

    // MARK: - Medium overprint  (360 × 170)

    private func mediumPrint(ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(ctx.appName.uppercased())
                    .font(.system(size: 9, design: .rounded).weight(.heavy))
                    .kerning(2.2)
                    .foregroundStyle(Color.black.opacity(0.48))
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.black.opacity(0.32))
                        .frame(width: 5, height: 5)
                    Text(ctx.statusText)
                        .font(.system(size: 9, design: .rounded).weight(.bold))
                        .foregroundStyle(Color.black.opacity(0.38))
                }
            }

            Spacer(minLength: 0)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(ctx.metricValue)
                    .font(.system(size: 70, design: .rounded).weight(.black))
                    .foregroundStyle(Color.black)
                    .shadow(color: Color(red: 0.975, green: 0.965, blue: 0.945).opacity(0.85), radius: 4)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ctx.metricUnit)
                        .font(.system(.title2, design: .rounded).weight(.heavy))
                        .foregroundStyle(ctx.accent)
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 15, design: .default).weight(.bold))
                        .foregroundStyle(ctx.accentSecondary)
                }
                .padding(.bottom, 6)
            }

            Text(ctx.metricCaption)
                .font(.system(size: 10, design: .rounded).weight(.medium))
                .foregroundStyle(Color.black.opacity(0.42))
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Large overprint  (360 × 376)

    private func largePrint(ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(ctx.appName.uppercased())
                    .font(.system(size: 10, design: .rounded).weight(.heavy))
                    .kerning(2.2)
                    .foregroundStyle(Color.black.opacity(0.44))
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.system(size: 14, design: .default).weight(.black))
                    .foregroundStyle(ctx.accent)
            }
            .padding(.bottom, 6)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(ctx.metricValue)
                    .font(.system(size: 90, design: .rounded).weight(.black))
                    .foregroundStyle(Color.black)
                    .shadow(color: Color(red: 0.975, green: 0.965, blue: 0.945).opacity(0.9), radius: 5)

                VStack(alignment: .leading, spacing: 3) {
                    Text(ctx.metricUnit)
                        .font(.system(.title, design: .rounded).weight(.heavy))
                        .foregroundStyle(ctx.accent)
                    Text(ctx.metricCaption)
                        .font(.system(size: 10, design: .rounded).weight(.medium))
                        .foregroundStyle(Color.black.opacity(0.38))
                        .lineLimit(2)
                        .frame(maxWidth: 110, alignment: .leading)
                }
                .padding(.bottom, 8)
            }

            Spacer(minLength: 10)

            progressDotBar(progress: ctx.progress, label: ctx.progressLabel, accent: ctx.accent)

            Spacer(minLength: 16)

            itemTable(items: ctx.items, accent: ctx.accent, secondary: ctx.accentSecondary)

            Spacer(minLength: 8)

            Text(ctx.updatedText)
                .font(.system(size: 8.5, design: .rounded).weight(.regular))
                .foregroundStyle(Color.black.opacity(0.26))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Progress dot bar

    private func progressDotBar(progress: Double, label: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label.uppercased())
                .font(.system(size: 8.5, design: .rounded).weight(.heavy))
                .kerning(1.4)
                .foregroundStyle(Color.black.opacity(0.36))
            Canvas { gc, size in
                let d: CGFloat = 7
                let g: CGFloat = 3
                let step = d + g
                let n    = Int(size.width / step)
                let fill = Int(Double(n) * progress)
                for i in 0..<n {
                    let x = CGFloat(i) * step + d / 2
                    let y = size.height / 2
                    var dot = Path()
                    dot.addEllipse(in: CGRect(x: x - d / 2, y: y - d / 2, width: d, height: d))
                    gc.fill(dot, with: .color(i < fill ? accent : Color.black.opacity(0.11)))
                }
            }
            .frame(height: 10)
        }
    }

    // MARK: - Item table

    private func itemTable(items: [ConceptContext.Item], accent: Color, secondary: Color) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.prefix(4).enumerated()), id: \.offset) { idx, item in
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(idx % 2 == 0 ? accent.opacity(0.75) : secondary.opacity(0.75))
                        .frame(width: 3, height: 14)
                    Text(item.title)
                        .font(.system(.footnote, design: .rounded).weight(.medium))
                        .foregroundStyle(Color.black.opacity(0.72))
                        .lineLimit(1)
                    Spacer()
                    Text(item.subtitle)
                        .font(.system(.footnote, design: .monospaced).weight(.semibold))
                        .foregroundStyle(secondary)
                }
                .padding(.vertical, 5)
                if idx < 3 {
                    Rectangle()
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 0.5)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
