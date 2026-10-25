import SwiftUI

// MARK: - Duotone Bold Concept

struct DuotoneBoldConcept: WidgetConcept {
    static let id                        = "duotone-bold"
    static let title                     = "Duotone Bold"
    static let blurb                     = "Two-color poster: near-black canvas, accent diagonal band, oversized high-contrast type."
    static let preferredScheme: ColorScheme = .dark

    private static let canvas = Color(red: 0.05, green: 0.05, blue: 0.08)

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                Self.canvas
                GeometryReader { geo in
                    if family == .medium {
                        mediumContent(ctx: ctx, size: geo.size)
                    } else {
                        largeContent(ctx: ctx, size: geo.size)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }

    // MARK: Medium (360 × 170)

    @ViewBuilder
    private func mediumContent(ctx: ConceptContext, size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            // Diagonal accent band — the graphic backbone
            DuotoneDiagonalBand(thickness: size.height * 0.62)
                .fill(ctx.accent)

            VStack(alignment: .leading, spacing: 0) {
                // Header row
                HStack {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .kerning(2)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(ctx.accent)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                Spacer(minLength: 0)

                // Hero metric — enormous poster-style number
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(ctx.metricValue)
                        .font(.system(size: 80, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(ctx.metricUnit)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 0)

                // Footer row
                HStack(alignment: .bottom) {
                    Text(ctx.metricCaption.uppercased())
                        .font(.system(size: 9, weight: .semibold))
                        .kerning(1.5)
                        .foregroundStyle(.white.opacity(0.65))
                    Spacer()
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(ctx.countValue)")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(.white)
                        Text(ctx.countCaption.uppercased())
                            .font(.system(size: 8, weight: .bold))
                            .kerning(1)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(2)
                            .frame(maxWidth: 80, alignment: .leading)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
            .frame(width: size.width, height: size.height)
        }
    }

    // MARK: Large (360 × 376)

    @ViewBuilder
    private func largeContent(ctx: ConceptContext, size: CGSize) -> some View {
        let circleD = size.width * 0.75
        ZStack(alignment: .topLeading) {
            // Accent circle bleeds off the top-right corner — geometric poster anchor
            Circle()
                .fill(ctx.accent)
                .frame(width: circleD, height: circleD)
                .offset(x: size.width - circleD * 0.55, y: -circleD * 0.30)

            VStack(alignment: .leading, spacing: 0) {
                // App name — small, uppercase, airy tracking
                Text(ctx.appName.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .kerning(2.5)
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.top, 20)

                // Enormous metric — left side is on dark bg, high contrast
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(ctx.metricValue)
                        .font(.system(size: 96, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ctx.metricUnit)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(ctx.accent)
                    }
                }
                .padding(.top, 4)

                Text(ctx.metricCaption.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .kerning(2)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 4)

                // Bold accent rule — section divider
                Rectangle()
                    .fill(ctx.accent)
                    .frame(height: 3)
                    .padding(.top, 18)

                // List section
                Text(ctx.listTitle.uppercased())
                    .font(.system(size: 9, weight: .black))
                    .kerning(2.5)
                    .foregroundStyle(ctx.accent)
                    .padding(.top, 14)

                ForEach(ctx.items) { item in
                    HStack {
                        Text(item.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Spacer()
                        Text(item.subtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(ctx.accent)
                    }
                    .padding(.vertical, 9)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.white.opacity(0.08))
                            .frame(height: 1)
                    }
                }

                Spacer(minLength: 0)

                // Progress bar
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { bar in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(.white.opacity(0.12))
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(ctx.accent)
                                .frame(width: bar.size.width * ctx.progress, height: 4)
                        }
                    }
                    .frame(height: 4)

                    Text(ctx.progressLabel.uppercased())
                        .font(.system(size: 8, weight: .semibold))
                        .kerning(1.5)
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .frame(width: size.width, height: size.height)
        }
    }
}

// MARK: - Shape

private struct DuotoneDiagonalBand: Shape {
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        // Parallelogram centered on the bottom-left → top-right diagonal
        let dx  = rect.width
        let dy  = rect.height
        let len = (dx * dx + dy * dy).squareRoot()
        // Unit vector perpendicular to the diagonal
        let px  =  dy / len
        let py  = -dx / len
        let ox  = px * thickness * 0.5
        let oy  = py * thickness * 0.5

        var path = Path()
        path.move(to:    CGPoint(x:               ox, y: rect.maxY + oy))
        path.addLine(to: CGPoint(x: rect.maxX +   ox, y:              oy))
        path.addLine(to: CGPoint(x: rect.maxX -   ox, y:             -oy))
        path.addLine(to: CGPoint(x:              -ox, y: rect.maxY - oy))
        path.closeSubpath()
        return path
    }
}
