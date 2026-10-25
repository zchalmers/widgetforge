import SwiftUI

/// Monochrome ink wash: grayscale paper ground, organic brush-stroke blob behind
/// the hero numeral, deep-black anchor, refined sparse type — zen calligraphy quiet.
struct MonochromeInkConcept: WidgetConcept {
    static let id = "monochrome-ink"
    static let title = "Monochrome Ink"
    static let blurb = "Grayscale ink wash, brush-stroke blob behind hero numerals, zen calligraphy quiet."
    static let preferredScheme: ColorScheme = .light

    // Palette — pure grayscale only
    private let paper    = Color(red: 0.97, green: 0.96, blue: 0.94)
    private let inkDeep  = Color(red: 0.08, green: 0.07, blue: 0.07)
    private let inkMid   = Color(red: 0.36, green: 0.35, blue: 0.34)
    private let inkLight = Color(red: 0.62, green: 0.61, blue: 0.60)
    private let inkTrace = Color(red: 0.86, green: 0.85, blue: 0.84)

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        switch family {
        case .medium: return AnyView(mediumBody(ctx: ctx, family: family))
        case .large:  return AnyView(largeBody(ctx: ctx, family: family))
        }
    }

    // MARK: - Medium  (360 × 170)

    @ViewBuilder
    private func mediumBody(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack(alignment: .leading) {
            paper

            // Soft ink-wash blob positioned behind the hero metric
            InkBlob()
                .fill(inkDeep.opacity(0.065))
                .blur(radius: 22)
                .frame(width: 218, height: 114)
                .offset(x: 16, y: 2)

            HStack(alignment: .center, spacing: 0) {
                // Left column — hero metric
                VStack(alignment: .leading, spacing: 0) {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 8.5, weight: .medium))
                        .tracking(2.5)
                        .foregroundStyle(inkLight)

                    Spacer(minLength: 6)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(ctx.metricValue)
                            .font(.system(size: 50, weight: .thin, design: .serif))
                            .foregroundStyle(inkDeep)
                        Text(ctx.metricUnit)
                            .font(.system(size: 17, weight: .light, design: .serif))
                            .foregroundStyle(inkMid)
                    }

                    Text(ctx.metricCaption)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(inkMid)
                        .padding(.top, 2)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Hairline column divider
                Rectangle()
                    .fill(inkTrace)
                    .frame(width: 0.75)
                    .padding(.vertical, 14)

                // Right column — count + status
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(size: 10, weight: .semibold))
                        Text(ctx.statusLevel.label.uppercased())
                            .font(.system(size: 8.5, weight: .semibold))
                            .tracking(1.5)
                    }
                    .foregroundStyle(inkDeep)

                    Text("\(ctx.countValue)")
                        .font(.system(size: 34, weight: .ultraLight, design: .serif))
                        .foregroundStyle(inkDeep)

                    Text(ctx.countCaption)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(inkMid)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    Text(ctx.updatedText)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(inkLight)
                }
                .padding(.leading, 14)
                .frame(width: 124, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Large  (360 × 376)

    @ViewBuilder
    private func largeBody(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack(alignment: .topLeading) {
            paper

            // Larger, softer wash blob behind the hero region
            InkBlob()
                .fill(inkDeep.opacity(0.052))
                .blur(radius: 40)
                .frame(width: 308, height: 158)
                .offset(x: 28, y: 26)

            VStack(alignment: .leading, spacing: 0) {
                // App name + trend indicator
                HStack {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 8.5, weight: .medium))
                        .tracking(2.5)
                        .foregroundStyle(inkLight)
                    Spacer()
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(inkDeep)
                }

                // Hero metric
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(ctx.metricValue)
                        .font(.system(size: 66, weight: .thin, design: .serif))
                        .foregroundStyle(inkDeep)
                    Text(ctx.metricUnit)
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundStyle(inkMid)
                }
                .padding(.top, 8)

                Text(ctx.metricCaption)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(inkMid)
                    .padding(.top, 1)

                // Separator
                Rectangle()
                    .fill(inkTrace)
                    .frame(height: 0.75)
                    .padding(.top, 18)

                // Progress row
                HStack {
                    Text("Progress".uppercased())
                        .font(.system(size: 8.5, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(inkLight)
                    Spacer()
                    Text(ctx.progressLabel)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(inkMid)
                }
                .padding(.top, 14)

                // Ink progress bar drawn via Canvas (no Charts import)
                let pv = ctx.progress
                let deep = inkDeep
                let trace = inkTrace
                Canvas { gfx, size in
                    gfx.fill(Path(CGRect(origin: .zero, size: size)),
                             with: .color(trace))
                    gfx.fill(Path(CGRect(x: 0, y: 0,
                                         width: size.width * pv,
                                         height: size.height)),
                             with: .color(deep))
                }
                .frame(height: 2.5)
                .padding(.top, 8)

                // Separator
                Rectangle()
                    .fill(inkTrace)
                    .frame(height: 0.75)
                    .padding(.top, 14)

                // Deal list section
                Text(ctx.listTitle.uppercased())
                    .font(.system(size: 8.5, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(inkLight)
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(ctx.items.prefix(3)) { item in
                        HStack {
                            Text(item.title)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(inkDeep)
                                .lineLimit(1)
                            Spacer()
                            Text(item.subtitle)
                                .font(.system(size: 11, weight: .light, design: .serif))
                                .foregroundStyle(inkMid)
                        }
                        .padding(.vertical, 8)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(inkTrace).frame(height: 0.75)
                        }
                    }
                }
                .padding(.top, 8)

                Spacer(minLength: 0)

                // Footer
                HStack(spacing: 6) {
                    Circle()
                        .fill(inkDeep.opacity(0.20))
                        .frame(width: 5, height: 5)
                    Text(ctx.updatedText)
                        .font(.system(size: 9.5, weight: .regular))
                        .foregroundStyle(inkLight)
                    Spacer()
                    Text(ctx.statusText)
                        .font(.system(size: 9.5, weight: .regular))
                        .foregroundStyle(inkMid)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }
}

// MARK: - InkBlob Shape

/// Organic, asymmetric closed cubic bezier — mimics an ink-brush wash mark.
/// The shape fills its given rect; sizing and blur are controlled at call sites.
private struct InkBlob: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX, cy = rect.midY
        let rx = rect.width  * 0.48
        let ry = rect.height * 0.46

        var p = Path()
        p.move(to: CGPoint(x: cx - rx,        y: cy + ry * 0.10))
        p.addCurve(
            to:       CGPoint(x: cx - rx * 0.08, y: cy - ry),
            control1: CGPoint(x: cx - rx * 0.95, y: cy - ry * 0.72),
            control2: CGPoint(x: cx - rx * 0.52, y: cy - ry * 0.96)
        )
        p.addCurve(
            to:       CGPoint(x: cx + rx,        y: cy - ry * 0.06),
            control1: CGPoint(x: cx + rx * 0.28, y: cy - ry * 1.03),
            control2: CGPoint(x: cx + rx * 0.88, y: cy - ry * 0.62)
        )
        p.addCurve(
            to:       CGPoint(x: cx + rx * 0.12, y: cy + ry),
            control1: CGPoint(x: cx + rx * 0.98, y: cy + ry * 0.66),
            control2: CGPoint(x: cx + rx * 0.58, y: cy + ry * 0.93)
        )
        p.addCurve(
            to:       CGPoint(x: cx - rx,        y: cy + ry * 0.10),
            control1: CGPoint(x: cx - rx * 0.22, y: cy + ry * 1.04),
            control2: CGPoint(x: cx - rx * 0.86, y: cy + ry * 0.74)
        )
        p.closeSubpath()
        return p
    }
}
