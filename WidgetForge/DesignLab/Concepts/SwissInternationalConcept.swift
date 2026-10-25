import SwiftUI

/// Swiss International Typographic Style: strict left-aligned grid, Helvetica-like
/// system font, a single red accent rule, precise baseline alignment, generous negative space.
struct SwissInternationalConcept: WidgetConcept {
    static let id = "swiss-international"
    static let title = "Swiss International"
    static let blurb = "Left-aligned grid, Helvetica-like type, single red accent, generous negative space."
    static let preferredScheme: ColorScheme = .light

    // Palette — pure white field, near-black ink, one Swiss red, hairline gray rules
    private static let swissRed   = Color(red: 0.93, green: 0.07, blue: 0.09)
    private static let ink        = Color(red: 0.06, green: 0.06, blue: 0.06)
    private static let smoke      = Color(red: 0.50, green: 0.50, blue: 0.50)
    private static let hairline   = Color(red: 0.84, green: 0.84, blue: 0.84)

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        if family == .medium {
            return AnyView(mediumLayout(ctx, family: family))
        } else {
            return AnyView(largeLayout(ctx, family: family))
        }
    }

    // MARK: — Medium (360 × 170)
    // Hero metric left, count + trend right, tight header + footer rows, lots of air.

    @ViewBuilder
    private func mediumLayout(_ ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack(alignment: .topLeading) {
            Color.white

            VStack(alignment: .leading, spacing: 0) {

                // ── Red top rule — the one accent ──────────────────────────
                Self.swissRed.frame(height: 3)

                // ── Header ─────────────────────────────────────────────────
                HStack(alignment: .center) {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 9, weight: .medium, design: .default))
                        .kerning(1.8)
                        .foregroundStyle(Self.smoke)
                    Spacer()
                    Text(ctx.updatedText)
                        .font(.system(size: 9, weight: .regular, design: .default))
                        .foregroundStyle(Self.smoke)
                }
                .padding(.horizontal, 18)
                .padding(.top, 11)
                .padding(.bottom, 10)

                Self.hairline.frame(height: 0.5).padding(.horizontal, 18)

                Spacer(minLength: 0)

                // ── Metric hero ────────────────────────────────────────────
                HStack(alignment: .top, spacing: 0) {

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text(ctx.metricValue)
                                .font(.system(size: 52, weight: .bold, design: .default))
                                .foregroundStyle(Self.ink)
                            Text(ctx.metricUnit)
                                .font(.system(size: 22, weight: .light, design: .default))
                                .foregroundStyle(Self.ink)
                        }
                        Text(ctx.metricCaption)
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundStyle(Self.smoke)
                    }

                    Spacer()

                    // Right column: trend + count
                    VStack(alignment: .trailing, spacing: 3) {
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(size: 18, weight: .thin))
                            .foregroundStyle(ctx.trend == .up ? Self.swissRed : Self.smoke)
                        Text("\(ctx.countValue)")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundStyle(Self.ink)
                        Text(ctx.countCaption)
                            .font(.system(size: 8, weight: .regular, design: .default))
                            .foregroundStyle(Self.smoke)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 84, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 18)

                Spacer(minLength: 0)

                // ── Footer rule + status ───────────────────────────────────
                Self.hairline.frame(height: 0.5).padding(.horizontal, 18)

                HStack(alignment: .center, spacing: 5) {
                    if ctx.statusLevel != .ok {
                        Rectangle()
                            .fill(Self.swissRed)
                            .frame(width: 5, height: 5)
                    }
                    Text(ctx.statusLevel.label.uppercased())
                        .font(.system(size: 8, weight: .medium, design: .default))
                        .kerning(1.2)
                        .foregroundStyle(ctx.statusLevel != .ok ? Self.swissRed : Self.smoke)
                    Spacer()
                    Text(ctx.statusText)
                        .font(.system(size: 9, weight: .regular, design: .default))
                        .foregroundStyle(Self.smoke)
                        .lineLimit(1)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: — Large (360 × 376)
    // Header → metric hero → progress bar → divider → item list → footer.

    @ViewBuilder
    private func largeLayout(_ ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack(alignment: .topLeading) {
            Color.white

            VStack(alignment: .leading, spacing: 0) {

                // ── Red top rule ───────────────────────────────────────────
                Self.swissRed.frame(height: 3)

                // ── Header ─────────────────────────────────────────────────
                HStack(alignment: .center) {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 9, weight: .medium, design: .default))
                        .kerning(1.8)
                        .foregroundStyle(Self.smoke)
                    Spacer()
                    Text(ctx.updatedText)
                        .font(.system(size: 9, weight: .regular, design: .default))
                        .foregroundStyle(Self.smoke)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 12)

                Self.hairline.frame(height: 0.5).padding(.horizontal, 20)

                // ── Metric hero ────────────────────────────────────────────
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(ctx.metricValue)
                        .font(.system(size: 60, weight: .bold, design: .default))
                        .foregroundStyle(Self.ink)
                    Text(ctx.metricUnit)
                        .font(.system(size: 24, weight: .light, design: .default))
                        .foregroundStyle(Self.ink)
                    Spacer()
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 22, weight: .thin))
                        .foregroundStyle(ctx.trend == .up ? Self.swissRed : Self.smoke)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Text(ctx.metricCaption)
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundStyle(Self.smoke)
                    .padding(.horizontal, 20)
                    .padding(.top, 2)

                // ── Progress bar ───────────────────────────────────────────
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(ctx.progressLabel)
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundStyle(Self.smoke)
                        Spacer()
                        Text("\(Int(ctx.progress * 100))%")
                            .font(.system(size: 10, weight: .semibold, design: .default))
                            .foregroundStyle(Self.ink)
                    }
                    // Thin 2pt track: gray field, red fill — precise horizontal rule
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Self.hairline)
                                .frame(height: 2)
                            Rectangle()
                                .fill(Self.swissRed)
                                .frame(width: geo.size.width * max(0, min(1, ctx.progress)), height: 2)
                        }
                    }
                    .frame(height: 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // ── Section divider ────────────────────────────────────────
                Self.hairline.frame(height: 0.5)
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                // ── List section label ─────────────────────────────────────
                Text(ctx.listTitle.uppercased())
                    .font(.system(size: 8, weight: .medium, design: .default))
                    .kerning(1.5)
                    .foregroundStyle(Self.smoke)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 4)

                // ── Items — strict left-aligned grid, red index numbers ────
                let clampedItems = Array(ctx.items.prefix(4))
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(clampedItems.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .center, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.system(size: 9, weight: .bold, design: .default))
                                .foregroundStyle(Self.swissRed)
                                .frame(width: 12, alignment: .leading)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.title)
                                    .font(.system(size: 11, weight: .medium, design: .default))
                                    .foregroundStyle(Self.ink)
                                    .lineLimit(1)
                                Text(item.subtitle)
                                    .font(.system(size: 9, weight: .regular, design: .default))
                                    .foregroundStyle(Self.smoke)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 7)

                        if index < clampedItems.count - 1 {
                            Self.hairline.frame(height: 0.5).padding(.horizontal, 20)
                        }
                    }
                }

                Spacer(minLength: 0)

                // ── Footer ─────────────────────────────────────────────────
                Self.hairline.frame(height: 0.5).padding(.horizontal, 20)

                HStack(alignment: .center, spacing: 5) {
                    if ctx.statusLevel != .ok {
                        Rectangle()
                            .fill(Self.swissRed)
                            .frame(width: 5, height: 5)
                    }
                    Text(ctx.statusText)
                        .font(.system(size: 9, weight: .regular, design: .default))
                        .foregroundStyle(ctx.statusLevel != .ok ? Self.swissRed : Self.smoke)
                        .lineLimit(1)
                    Spacer()
                    Text("\(ctx.countValue)")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .foregroundStyle(Self.ink)
                    Text(ctx.countCaption)
                        .font(.system(size: 9, weight: .regular, design: .default))
                        .foregroundStyle(Self.smoke)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 9)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }
}
