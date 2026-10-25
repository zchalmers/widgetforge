import SwiftUI

// Static helpers are actor-isolation-free and callable from Canvas closures.
@MainActor
struct ContourTopoConcept: WidgetConcept {

    static let id              = "contour-topo"
    static let title           = "Topographic Contour"
    static let blurb           = "Nested ink-line contours ripple from the hero metric on aged cream — innermost valley brimming with teal."
    static let preferredScheme: ColorScheme = .light

    // MARK: - WidgetConcept body

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                Self.cream
                Canvas { gc, size in
                    Self.drawMap(gc: &gc, size: size, ctx: ctx, family: family)
                }
                if family == .medium {
                    mediumOverlay(ctx: ctx)
                } else {
                    largeOverlay(ctx: ctx)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }

    // MARK: - Canvas drawing (static = no actor isolation)

    private static let cream = Color(red: 0.957, green: 0.933, blue: 0.882)
    private static let ink   = Color(red: 0.160, green: 0.120, blue: 0.060)

    private static func drawMap(gc: inout GraphicsContext, size: CGSize,
                                ctx: ConceptContext, family: ConceptFamily) {
        let isLg    = family == .large
        let cx: CGFloat  = size.width  * 0.50
        let cy: CGFloat  = isLg ? size.height * 0.40 : size.height * 0.50
        let rings        = isLg ? 15 : 10
        let baseRx: CGFloat = isLg ? size.width  * 0.62 : size.width  * 0.52
        let baseRy: CGFloat = isLg ? size.height * 0.38 : size.height * 0.60
        let seed: CGFloat   = CGFloat(ctx.countValue) / 10.0          // 0.7
        let ph0: CGFloat    = CGFloat(ctx.progress) * .pi * 2.0       // ~3.9 rad

        // Outer → inner so accent valley fills land on top of outer lines
        for i in stride(from: rings, through: 1, by: -1) {
            let t: CGFloat   = CGFloat(i) / CGFloat(rings)
            let rx = baseRx * t
            let ry = baseRy * t
            let harm         = (i % 3) + 3                            // cycles 3,4,5
            let amp: CGFloat = 0.07 + 0.05 * seed * (1.0 - t)
            let ph: CGFloat  = ph0 + CGFloat(i) * 0.45
            let ring = topoRing(cx: cx, cy: cy, rx: rx, ry: ry,
                                harm: harm, amp: amp, ph: ph)

            // Accent-filled valley: innermost three rings graduate from solid → ghost
            if      i == 1 { gc.fill(ring, with: .color(ctx.accent)) }
            else if i == 2 { gc.fill(ring, with: .color(ctx.accent.opacity(0.28))) }
            else if i == 3 { gc.fill(ring, with: .color(ctx.accent.opacity(0.10))) }

            // Thin ink contour line — darkens toward summit
            let alpha = 0.10 + 0.40 * (1.0 - Double(t))
            gc.stroke(ring,
                      with: .color(ink.opacity(alpha)),
                      lineWidth: i <= 2 ? 1.4 : 0.7)
        }

        // Cartographic index ticks on every 4th contour
        for i in stride(from: rings - 1, through: 3, by: -4) {
            let t: CGFloat   = CGFloat(i) / CGFloat(rings)
            let amp: CGFloat = 0.07 + 0.05 * seed * (1.0 - t)
            let ph: CGFloat  = ph0 + CGFloat(i) * 0.45
            drawTicks(gc: &gc, cx: cx, cy: cy,
                      rx: baseRx * t, ry: baseRy * t,
                      harm: (i % 3) + 3, amp: amp, ph: ph,
                      alpha: 0.12 + 0.22 * (1.0 - Double(t)))
        }
    }

    /// Perturbed ellipse path — one closed contour ring.
    private static func topoRing(cx: CGFloat, cy: CGFloat,
                                 rx: CGFloat, ry: CGFloat,
                                 harm: Int, amp: CGFloat, ph: CGFloat,
                                 steps: Int = 96) -> Path {
        var p = Path()
        for i in 0...steps {
            let θ: CGFloat = CGFloat(i) / CGFloat(steps) * .pi * 2.0
            let r: CGFloat = 1.0 + amp * sin(CGFloat(harm) * θ + ph)
            let pt = CGPoint(x: cx + rx * r * cos(θ), y: cy + ry * r * sin(θ))
            i == 0 ? p.move(to: pt) : p.addLine(to: pt)
        }
        p.closeSubpath()
        return p
    }

    /// Short radial tick marks along a contour ring (cartographic hachure).
    private static func drawTicks(gc: inout GraphicsContext,
                                  cx: CGFloat, cy: CGFloat,
                                  rx: CGFloat, ry: CGFloat,
                                  harm: Int, amp: CGFloat, ph: CGFloat, alpha: Double) {
        for j in 0..<12 {
            let θ: CGFloat = CGFloat(j) / 12.0 * .pi * 2.0
            let r: CGFloat = 1.0 + amp * sin(CGFloat(harm) * θ + ph)
            let ox = cx + rx * r * cos(θ)
            let oy = cy + ry * r * sin(θ)
            var tick = Path()
            tick.move(to:    CGPoint(x: ox - cos(θ) * 3.0, y: oy - sin(θ) * 3.0))
            tick.addLine(to: CGPoint(x: ox + cos(θ) * 3.0, y: oy + sin(θ) * 3.0))
            gc.stroke(tick, with: .color(ink.opacity(alpha)), lineWidth: 0.75)
        }
    }

    // MARK: - Text overlays (@MainActor instance methods)

    @ViewBuilder
    private func mediumOverlay(ctx: ConceptContext) -> some View {
        VStack(spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(ctx.metricValue)
                    .font(.system(size: 54, weight: .black, design: .serif))
                    .foregroundStyle(Self.ink)
                    .shadow(color: Self.cream.opacity(0.88), radius: 6)
                Text(ctx.metricUnit)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(Self.ink.opacity(0.55))
                    .shadow(color: Self.cream.opacity(0.88), radius: 4)
            }
            Text(ctx.metricCaption)
                .font(.system(size: 9, weight: .regular, design: .default))
                .kerning(1.6)
                .textCase(.uppercase)
                .foregroundStyle(Self.ink.opacity(0.45))
        }
    }

    @ViewBuilder
    private func largeOverlay(ctx: ConceptContext) -> some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Text(ctx.appName.uppercased())
                    .font(.system(size: 9, weight: .semibold, design: .default))
                    .kerning(2.2)
                    .foregroundStyle(Self.ink.opacity(0.40))
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(ctx.accent)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Spacer().frame(height: 14)

            // Hero metric — positioned near the contour summit
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(ctx.metricValue)
                    .font(.system(size: 72, weight: .black, design: .serif))
                    .foregroundStyle(Self.ink)
                    .shadow(color: Self.cream.opacity(0.78), radius: 8)
                Text(ctx.metricUnit)
                    .font(.system(size: 25, weight: .semibold, design: .serif))
                    .foregroundStyle(Self.ink.opacity(0.55))
                    .baselineOffset(8)
                    .shadow(color: Self.cream.opacity(0.78), radius: 5)
            }
            Text(ctx.metricCaption)
                .font(.system(size: 9.5, weight: .regular, design: .default))
                .kerning(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Self.ink.opacity(0.40))

            Spacer()

            // Bottom data strip
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Self.ink.opacity(0.12))
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)
                ForEach(Array(ctx.items.prefix(4).enumerated()), id: \.offset) { idx, item in
                    HStack {
                        Text(item.title)
                            .font(.system(size: 11, weight: .regular, design: .default))
                            .foregroundStyle(Self.ink.opacity(0.65))
                        Spacer()
                        Text(item.subtitle)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(ctx.accent)
                    }
                    .padding(.vertical, 5.5)
                    .padding(.horizontal, 20)
                    if idx < 3 {
                        Rectangle()
                            .fill(Self.ink.opacity(0.07))
                            .frame(height: 0.5)
                            .padding(.horizontal, 20)
                    }
                }
                Text(ctx.updatedText)
                    .font(.system(size: 8, weight: .light, design: .default))
                    .kerning(0.4)
                    .foregroundStyle(Self.ink.opacity(0.28))
                    .padding(.top, 5)
                    .padding(.bottom, 10)
            }
            .background(Self.cream.opacity(0.62))
        }
    }
}
