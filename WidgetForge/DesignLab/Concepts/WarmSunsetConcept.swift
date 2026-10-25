import SwiftUI

/// Warm sunset: vertical orange-to-pink-to-deep-purple gradient, soft radial
/// glow bloom, cream text, and a horizon-line progress bar. Golden-hour mood.
struct WarmSunsetConcept: WidgetConcept {
    static let id = "warm-sunset"
    static let title = "Warm Sunset"
    static let blurb = "Orange-to-purple golden-hour gradient, soft glow bloom, cream text."
    static let preferredScheme: ColorScheme = .dark

    // MARK: – Palette
    private let sunOrange  = Color(red: 1.00, green: 0.52, blue: 0.18)
    private let flamePink  = Color(red: 0.98, green: 0.30, blue: 0.50)
    private let duskViolet = Color(red: 0.46, green: 0.20, blue: 0.70)
    private let deepNight  = Color(red: 0.12, green: 0.05, blue: 0.26)
    private let cream      = Color(red: 1.00, green: 0.94, blue: 0.82)
    private let glowAmber  = Color(red: 1.00, green: 0.66, blue: 0.22)

    // MARK: – Entry point

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        switch family {
        case .medium: return AnyView(mediumLayout(ctx: ctx, family: family))
        case .large:  return AnyView(largeLayout(ctx: ctx, family: family))
        }
    }

    // MARK: – Shared sub-views

    @ViewBuilder
    private func sunsetGradient() -> some View {
        LinearGradient(
            stops: [
                .init(color: sunOrange,  location: 0.00),
                .init(color: flamePink,  location: 0.42),
                .init(color: duskViolet, location: 0.74),
                .init(color: deepNight,  location: 1.00)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    @ViewBuilder
    private func glowBlob(offsetX: CGFloat, offsetY: CGFloat, radius: CGFloat, opacity: Double = 1) -> some View {
        RadialGradient(
            colors: [glowAmber.opacity(0.60 * opacity), .clear],
            center: .center,
            startRadius: 0,
            endRadius: radius
        )
        .frame(width: radius * 2, height: radius * 2)
        .offset(x: offsetX, y: offsetY)
        .blendMode(.screen)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func metricHero(value: String, unit: String, fontSize: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(value)
                .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                .foregroundStyle(cream)
            Text(unit)
                .font(.system(size: fontSize * 0.40, weight: .semibold, design: .rounded))
                .foregroundStyle(cream.opacity(0.72))
                .baselineOffset(fontSize * 0.08)
        }
    }

    @ViewBuilder
    private func trendRow(ctx: ConceptContext) -> some View {
        HStack(spacing: 4) {
            Image(systemName: ctx.trend.symbol)
                .font(.system(size: 10, weight: .bold))
            Text(ctx.metricCaption)
                .font(.system(size: 11, weight: .medium, design: .rounded))
        }
        .foregroundStyle(cream.opacity(0.75))
    }

    @ViewBuilder
    private func horizonBar(progress: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(cream.opacity(0.18))
                    .frame(height: 4)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [sunOrange, flamePink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(8, geo.size.width * CGFloat(min(max(progress, 0), 1))),
                        height: 4
                    )
            }
        }
        .frame(height: 4)
    }

    // MARK: – Medium layout (360 × 170)

    private func mediumLayout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            sunsetGradient()
            glowBlob(offsetX: -50, offsetY: 30, radius: 110)

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    Label(ctx.appName, systemImage: "sun.horizon.fill")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(cream.opacity(0.90))
                        .labelStyle(
                            TintedIconLabelStyle(iconColor: glowAmber)
                        )
                    Spacer()
                    Text(ctx.updatedText)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(cream.opacity(0.45))
                }

                Spacer(minLength: 0)

                // Metric hero
                metricHero(value: ctx.metricValue, unit: ctx.metricUnit, fontSize: 48)

                trendRow(ctx: ctx)
                    .padding(.top, 3)

                Spacer(minLength: 10)

                // Horizon bar + label
                horizonBar(progress: ctx.progress)
                Text(ctx.progressLabel)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(cream.opacity(0.48))
                    .padding(.top, 5)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: – Large layout (360 × 376)

    private func largeLayout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            sunsetGradient()
            glowBlob(offsetX: -60, offsetY: -50, radius: 140)
            glowBlob(offsetX: 90,  offsetY:  80, radius: 80, opacity: 0.60)

            VStack(alignment: .leading, spacing: 0) {

                // Header row
                HStack {
                    Label(ctx.appName, systemImage: "sun.horizon.fill")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(cream.opacity(0.90))
                        .labelStyle(TintedIconLabelStyle(iconColor: glowAmber))
                    Spacer()
                    statusPill(ctx: ctx)
                }

                Spacer(minLength: 14)

                // Metric hero (large)
                metricHero(value: ctx.metricValue, unit: ctx.metricUnit, fontSize: 60)
                trendRow(ctx: ctx).padding(.top, 4)

                Spacer(minLength: 16)

                // Progress section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(ctx.progressLabel)
                            .font(.system(size: 11, design: .rounded).weight(.medium))
                            .foregroundStyle(cream.opacity(0.65))
                        Spacer()
                        Text("\(Int(ctx.progress * 100))%")
                            .font(.system(size: 11, design: .rounded).weight(.bold))
                            .foregroundStyle(sunOrange)
                    }
                    horizonBar(progress: ctx.progress)
                }

                Spacer(minLength: 18)

                // List header
                HStack(alignment: .firstTextBaseline) {
                    Text(ctx.listTitle)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(cream.opacity(0.52))
                        .textCase(.uppercase)
                        .tracking(0.8)
                    Spacer()
                    Text("\(ctx.countValue) ")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(flamePink)
                    + Text(ctx.countCaption.lowercased())
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(cream.opacity(0.42))
                }

                Spacer(minLength: 10)

                // Deal list card
                VStack(spacing: 0) {
                    ForEach(Array(ctx.items.prefix(4).enumerated()), id: \.offset) { idx, item in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [sunOrange, flamePink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 7, height: 7)
                            Text(item.title)
                                .font(.system(.footnote, design: .rounded).weight(.medium))
                                .foregroundStyle(cream.opacity(0.88))
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text(item.subtitle)
                                .font(.system(size: 11, design: .rounded).weight(.semibold))
                                .foregroundStyle(glowAmber)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)

                        if idx < min(ctx.items.count, 4) - 1 {
                            Rectangle()
                                .fill(cream.opacity(0.10))
                                .frame(height: 1)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(cream.opacity(0.07),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Spacer(minLength: 0)

                // Footer
                Text(ctx.updatedText)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(cream.opacity(0.36))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: – Status pill

    @ViewBuilder
    private func statusPill(ctx: ConceptContext) -> some View {
        let dotColor: Color = {
            switch ctx.statusLevel {
            case .ok:       return sunOrange
            case .warning:  return flamePink
            case .critical: return Color(red: 1.0, green: 0.28, blue: 0.28)
            }
        }()
        HStack(spacing: 5) {
            Circle().fill(dotColor).frame(width: 6, height: 6)
            Text(ctx.statusLevel.label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(cream.opacity(0.85))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(cream.opacity(0.11), in: Capsule())
    }
}

// MARK: – Helpers

/// A LabelStyle that tints the icon independently from the title.
private struct TintedIconLabelStyle: LabelStyle {
    let iconColor: Color
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon.foregroundStyle(iconColor)
            configuration.title
        }
    }
}
