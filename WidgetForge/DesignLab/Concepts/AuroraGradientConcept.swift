import SwiftUI

/// Aurora borealis: soft flowing gradient ribbons of teal, violet, and green
/// blurred over a deep-night background. Ethereal glowing type, dreamy atmosphere.
struct AuroraGradientConcept: WidgetConcept {

    static let id               = "aurora-gradient"
    static let title            = "Aurora Gradient"
    static let blurb            = "Aurora borealis ribbons of teal, violet, and green glow over a deep-night sky."
    static let preferredScheme: ColorScheme = .dark

    // Night-sky palette
    private let night  = Color(red: 0.03, green: 0.05, blue: 0.12)
    private let teal   = Color(red: 0.15, green: 0.95, blue: 0.80)
    private let violet = Color(red: 0.55, green: 0.35, blue: 1.00)
    private let green  = Color(red: 0.20, green: 0.90, blue: 0.55)
    private let cyan   = Color(red: 0.10, green: 0.78, blue: 0.98)

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                night
                auroraRibbons(family: family)
                if family == .medium {
                    mediumContent(ctx: ctx)
                } else {
                    largeContent(ctx: ctx)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }

    // MARK: – Aurora background

    @ViewBuilder
    private func auroraRibbons(family: ConceptFamily) -> some View {
        let bloomRadius: CGFloat = family == .large ? 220 : 130
        ZStack {
            // Primary teal → violet diagonal sweep
            LinearGradient(
                colors: [teal.opacity(0.55), violet.opacity(0.25), .clear],
                startPoint: .topLeading,
                endPoint: UnitPoint(x: 0.75, y: 0.55)
            )
            .blendMode(.screen)
            .blur(radius: 28)

            // Green horizontal band across the mid-field
            LinearGradient(
                colors: [.clear, green.opacity(0.42), .clear],
                startPoint: UnitPoint(x: 0.0, y: 0.38),
                endPoint: UnitPoint(x: 0.85, y: 0.50)
            )
            .blendMode(.screen)
            .blur(radius: 22)

            // Violet radial bloom anchored bottom-right
            RadialGradient(
                colors: [violet.opacity(0.55), .clear],
                center: UnitPoint(x: 0.82, y: 0.90),
                startRadius: 0,
                endRadius: bloomRadius
            )
            .blendMode(.screen)

            // Cyan streak through the top-centre
            LinearGradient(
                colors: [.clear, cyan.opacity(0.32), .clear],
                startPoint: UnitPoint(x: 0.25, y: 0.0),
                endPoint: UnitPoint(x: 0.65, y: 0.45)
            )
            .blendMode(.screen)
            .blur(radius: 18)

            // Soft teal corona at top-left
            RadialGradient(
                colors: [teal.opacity(0.28), .clear],
                center: UnitPoint(x: 0.12, y: 0.08),
                startRadius: 0,
                endRadius: 90
            )
            .blendMode(.screen)
        }
    }

    // MARK: – Medium (360 × 170)

    @ViewBuilder
    private func mediumContent(ctx: ConceptContext) -> some View {
        HStack(alignment: .center, spacing: 0) {

            // Left column: metric hero
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Text(ctx.appName)
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.70))
                    Spacer()
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(teal)
                        .shadow(color: teal.opacity(0.90), radius: 5)
                }
                .padding(.bottom, 7)

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(ctx.metricValue)
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: teal.opacity(0.55), radius: 10)
                    Text(ctx.metricUnit)
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.58))
                }

                Text(ctx.metricCaption)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.50))
                    .padding(.top, 3)

                Spacer(minLength: 0)

                Text(ctx.updatedText)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(.white.opacity(0.28))
            }
            .padding(.leading, 18)
            .padding(.trailing, 14)
            .padding(.vertical, 16)

            // Gradient hairline divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.15), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1)
                .padding(.vertical, 18)

            // Right column: count + progress
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 6) {
                    Text("\(ctx.countValue)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(violet)
                        .shadow(color: violet.opacity(0.80), radius: 8)
                    Text(ctx.countCaption)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }
                .padding(.bottom, 10)

                // Aurora progress bar
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(.white.opacity(0.09))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [teal, green.opacity(0.85), violet],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(0, geo.size.width * ctx.progress), height: 6)
                                .shadow(color: teal.opacity(0.70), radius: 5)
                        }
                    }
                    .frame(height: 6)

                    Text(ctx.progressLabel)
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(.white.opacity(0.38))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.leading, 14)
            .padding(.trailing, 18)
            .padding(.vertical, 16)
        }
    }

    // MARK: – Large (360 × 376)

    @ViewBuilder
    private func largeContent(ctx: ConceptContext) -> some View {
        let rowColors: [Color] = [teal, violet, green]

        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                Text(ctx.appName)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 11, weight: .bold))
                    Text(ctx.statusLevel.label)
                        .font(.system(.caption, design: .rounded).weight(.medium))
                }
                .foregroundStyle(teal)
                .shadow(color: teal.opacity(0.75), radius: 6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 10)

            // Metric hero
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(ctx.metricValue)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: teal.opacity(0.50), radius: 14)
                Text(ctx.metricUnit)
                    .font(.system(.title2, design: .rounded).weight(.medium))
                    .foregroundStyle(.white.opacity(0.56))
            }
            .padding(.horizontal, 20)

            Text(ctx.metricCaption)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.50))
                .padding(.horizontal, 20)
                .padding(.top, 3)
                .padding(.bottom, 14)

            // Aurora progress bar
            VStack(alignment: .leading, spacing: 5) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(.white.opacity(0.09))
                            .frame(height: 7)
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [teal, green.opacity(0.85), violet],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geo.size.width * ctx.progress), height: 7)
                            .shadow(color: teal.opacity(0.65), radius: 5)
                    }
                }
                .frame(height: 7)

                Text(ctx.progressLabel)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.46))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // Status pill + count row
            HStack(spacing: 10) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(violet)
                        .frame(width: 6, height: 6)
                        .shadow(color: violet.opacity(0.90), radius: 4)
                    Text(ctx.statusText)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.07))
                        .overlay(
                            Capsule().strokeBorder(.white.opacity(0.13), lineWidth: 0.5)
                        )
                )

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(ctx.countValue)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(violet)
                        .shadow(color: violet.opacity(0.75), radius: 6)
                    Text(ctx.countCaption)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            // Section divider
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

            // List title
            Text(ctx.listTitle)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(.white.opacity(0.42))
                .textCase(.uppercase)
                .kerning(0.6)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)

            // List rows (3 items with cycling aurora accent bars)
            let displayItems = Array(ctx.items.prefix(3))
            ForEach(displayItems.indices, id: \.self) { i in
                let item = displayItems[i]
                let rowColor = rowColors[i % rowColors.count]
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(rowColor)
                        .frame(width: 3, height: 22)
                        .shadow(color: rowColor.opacity(0.85), radius: 4)
                        .padding(.leading, 20)
                        .padding(.trailing, 10)

                    Text(item.title)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)

                    Spacer()

                    Text(item.subtitle)
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(rowColor)
                        .shadow(color: rowColor.opacity(0.55), radius: 3)
                        .padding(.trailing, 20)
                }
                .frame(height: 34)
                .background(i % 2 == 1 ? .white.opacity(0.03) : .clear)
            }

            Spacer(minLength: 0)

            // Footer
            Text(ctx.updatedText)
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(.white.opacity(0.28))
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
        }
    }
}
