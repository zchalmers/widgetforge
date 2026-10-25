import SwiftUI

// MARK: – BokehDepthConcept

@MainActor
struct BokehDepthConcept: WidgetConcept {

    static let id              = "bokeh-depth"
    static let title           = "Bokeh Depth"
    static let blurb           = "Soft bokeh orbs in accent hues float behind a crisp frosted-glass panel."
    static let preferredScheme: ColorScheme = .dark

    init() {}

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(rootView(ctx: ctx, family: family))
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Root

    private func rootView(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            deepBackground(ctx: ctx)
            bokehField(ctx: ctx, isLarge: family == .large)
            panel(ctx: ctx, family: family)
        }
        .frame(width: family.size.width, height: family.size.height)
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Background

    private func deepBackground(ctx: ConceptContext) -> some View {
        ZStack {
            Color(red: 0.04, green: 0.03, blue: 0.09)
            LinearGradient(
                colors: [ctx.accentSecondary.opacity(0.18), ctx.accent.opacity(0.10)],
                startPoint: .topTrailing, endPoint: .bottomLeading
            )
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Bokeh field

    private func bokehField(ctx: ConceptContext, isLarge: Bool) -> some View {
        Canvas { gc, size in
            let count = isLarge ? 46 : 28
            for i in 0 ..< count {
                let f      = Double(i)
                let px     = fract(f * 0.61803) * size.width
                let py     = fract(f * 0.38197) * size.height
                let t      = fract(f * 0.12345 + 0.3)
                let radius = 5.0 + t * (isLarge ? 58.0 : 42.0)
                let blurR  = radius * 0.52 + 5.0
                let alpha  = 0.14 + fract(f * 0.54321) * 0.34
                let col: Color = (i % 7 == 0) ? .white
                               : (i % 3 == 2  ? ctx.accentSecondary : ctx.accent)
                gc.drawLayer { layer in
                    layer.addFilter(.blur(radius: blurR))
                    layer.fill(
                        Path(ellipseIn: CGRect(x: px - radius, y: py - radius,
                                               width: radius * 2, height: radius * 2)),
                        with: .color(col.opacity(alpha))
                    )
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Panel routing

    private func panel(ctx: ConceptContext, family: ConceptFamily) -> some View {
        Group {
            if family == .large {
                largePanel(ctx: ctx, family: family)
            } else {
                mediumPanel(ctx: ctx, family: family)
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Medium panel  (360 × 170)

    private func mediumPanel(ctx: ConceptContext, family: ConceptFamily) -> some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(ctx.accent)
                    Text(ctx.appName)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(ctx.metricValue)
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(ctx.metricUnit)
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                        .foregroundStyle(ctx.accent)
                }
                Text(ctx.metricCaption)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            VStack(alignment: .center, spacing: 8) {
                progressRing(ctx.progress, accent: ctx.accent, size: 64)
                Text(ctx.progressLabel)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 70)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(glassBackground(cornerRadius: family.cornerRadius - 4))
        .padding(8)
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Large panel  (360 × 376)

    private func largePanel(ctx: ConceptContext, family: ConceptFamily) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(ctx.appName)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(ctx.updatedText)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.38))
                }
                Spacer()
                Label(ctx.statusText, systemImage: "circle.fill")
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(Capsule().fill(.white.opacity(0.10)))
            }
            .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 14)

            Rectangle().fill(.white.opacity(0.12)).frame(height: 0.5)

            // Hero metric + progress ring
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(ctx.metricValue)
                            .font(.system(size: 66, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(ctx.metricUnit)
                            .font(.system(.title, design: .rounded).weight(.semibold))
                            .foregroundStyle(ctx.accent)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(.caption, design: .rounded).weight(.bold))
                        Text(ctx.metricCaption)
                            .font(.system(.caption, design: .rounded))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                VStack(spacing: 5) {
                    progressRing(ctx.progress, accent: ctx.accent, size: 76)
                    Text(ctx.progressLabel)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 84)
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 18)

            Rectangle().fill(.white.opacity(0.12)).frame(height: 0.5)

            // List items
            VStack(alignment: .leading, spacing: 0) {
                Text(ctx.listTitle)
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 8)
                ForEach(ctx.items) { item in
                    HStack {
                        Text(item.title)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.white.opacity(0.82))
                            .lineLimit(1)
                        Spacer()
                        Text(item.subtitle)
                            .font(.system(.footnote, design: .rounded).weight(.semibold))
                            .foregroundStyle(ctx.accent)
                    }
                    .padding(.vertical, 7)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(.white.opacity(0.09)).frame(height: 0.5)
                    }
                }
            }
            .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(glassBackground(cornerRadius: family.cornerRadius - 4))
        .padding(8)
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: Shared helpers

    private func glassBackground(cornerRadius cr: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cr, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cr, style: .continuous)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 0.75)
            )
    }

    private func progressRing(_ progress: Double, accent: Color, size: CGFloat) -> some View {
        Canvas { gc, sz in
            let c      = CGPoint(x: sz.width / 2, y: sz.height / 2)
            let r      = sz.width / 2 - 5
            let startA = Angle.degrees(-90)
            let endA   = Angle.degrees(-90 + 360 * progress)
            var track  = Path()
            track.addArc(center: c, radius: r,
                         startAngle: startA, endAngle: .degrees(270), clockwise: false)
            gc.stroke(track, with: .color(.white.opacity(0.13)), lineWidth: 4)
            var fill = Path()
            fill.addArc(center: c, radius: r,
                        startAngle: startA, endAngle: endA, clockwise: false)
            gc.stroke(fill, with: .color(accent),
                      style: StrokeStyle(lineWidth: 4, lineCap: .round))
        }
        .frame(width: size, height: size)
        .overlay(
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        )
    }

    private func fract(_ x: Double) -> Double { x - floor(x) }
}
