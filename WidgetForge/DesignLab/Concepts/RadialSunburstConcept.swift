import SwiftUI

@MainActor
struct RadialSunburstConcept: WidgetConcept {

    static let id              = "radial-sunburst"
    static let title           = "Radial Sunburst"
    static let blurb           = "Warm wedge-rays shaped by deal data; the golden arc shows live progress in the hub."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(layout(ctx: ctx, family: family))
    }

    // MARK: - Private layout

    private func layout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        let isLarge     = family == .large
        let W           = family.size.width
        let H           = family.size.height
        let cx: CGFloat = W / 2
        let cy: CGFloat = isLarge ? H * 0.38 : H / 2
        let maxR: CGFloat = isLarge ? H * 0.35 : H * 0.46
        let hubR: CGFloat = maxR * 0.30
        let numRays     = 52
        let progress    = CGFloat(ctx.progress)
        let count       = CGFloat(ctx.countValue)

        return ZStack {
            // ── background ────────────────────────────────────────
            LinearGradient(
                colors: [
                    Color(hue: 0.055, saturation: 1.0, brightness: 0.09),
                    Color(hue: 0.020, saturation: 1.0, brightness: 0.04),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            // warm bloom behind burst
            RadialGradient(
                colors: [
                    Color(hue: 0.09, saturation: 0.85, brightness: 0.80, opacity: 0.20),
                    .clear,
                ],
                center: UnitPoint(x: cx / W, y: cy / H),
                startRadius: 0,
                endRadius: maxR * 0.85
            )
            .blendMode(.screen)

            // ── sunburst canvas ───────────────────────────────────
            Canvas { gc, _ in
                let gap: CGFloat   = 0.015
                let sweep: CGFloat = (.pi * 2 / CGFloat(numRays)) - gap

                for i in 0 ..< numRays {
                    let t      = CGFloat(i) / CGFloat(numRays)
                    let angle  = t * .pi * 2 - .pi / 2

                    // length: sine wave seeded by countValue, boosted inside progress arc
                    let wave   = 0.5 + 0.5 * sin(t * .pi * 2 * count * 0.5 + progress * .pi * 1.5)
                    let boost: CGFloat = t < progress ? 0.20 : 0.00
                    let frac   = max(0.30, min(1.0, 0.50 + 0.50 * wave + boost))
                    let outer  = hubR + (maxR - hubR) * frac

                    var path = Path()
                    path.move(to: CGPoint(x: cx, y: cy))
                    path.addArc(
                        center:     CGPoint(x: cx, y: cy),
                        radius:     outer,
                        startAngle: Angle(radians: angle),
                        endAngle:   Angle(radians: angle + sweep),
                        clockwise:  false
                    )
                    path.closeSubpath()

                    // progress arc: gold-amber → warm red-ember beyond
                    let inProg     = t < progress
                    let hue: CGFloat = inProg
                        ? 0.085 + 0.055 * (t / max(progress, 0.01))
                        : 0.015 + 0.025 * ((t - progress) / max(1 - progress, 0.01))
                    let bri: CGFloat   = inProg ? 0.75 + 0.25 * (t / max(progress, 0.01)) : 0.44
                    let alpha: CGFloat = inProg ? 0.90 : 0.34

                    gc.fill(path, with: .color(
                        Color(hue: hue, saturation: 0.93, brightness: bri, opacity: alpha)
                    ))
                }

                // soft glow halo
                let haloR = hubR * 1.65
                var halo  = Path()
                halo.addEllipse(in: CGRect(x: cx - haloR, y: cy - haloR,
                                           width: haloR * 2, height: haloR * 2))
                gc.fill(halo, with: .color(
                    Color(hue: 0.09, saturation: 0.80, brightness: 1.0, opacity: 0.10)
                ))

                // dark hub disc + accent ring
                var hub = Path()
                hub.addEllipse(in: CGRect(x: cx - hubR, y: cy - hubR,
                                          width: hubR * 2, height: hubR * 2))
                gc.fill(hub, with: .color(
                    Color(hue: 0.05, saturation: 0.90, brightness: 0.07, opacity: 0.97)
                ))
                gc.stroke(hub,
                          with: .color(Color(hue: 0.11, saturation: 0.85, brightness: 0.95, opacity: 0.65)),
                          style: StrokeStyle(lineWidth: 1.5))
            }
            .frame(width: W, height: H)

            // ── hub hero text ─────────────────────────────────────
            VStack(spacing: isLarge ? 3 : 1) {
                Text("\(Int(round(ctx.progress * 100)))%")
                    .font(.system(size: isLarge ? 30 : 18, design: .rounded).weight(.bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hue: 0.13, saturation: 0.55, brightness: 1.00),
                                Color(hue: 0.07, saturation: 0.90, brightness: 1.00),
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(hue: 0.09, saturation: 1.0, brightness: 1.0, opacity: 0.60),
                            radius: 6)
                Text(ctx.progressLabel)
                    .font(.system(size: isLarge ? 7 : 6, design: .rounded).weight(.medium))
                    .foregroundStyle(.white.opacity(0.42))
                    .lineLimit(1)
            }
            .position(x: cx, y: cy)

            // ── metric value / unit ───────────────────────────────
            if isLarge {
                VStack(spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(ctx.metricValue)
                            .font(.system(size: 22, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                        Text(ctx.metricUnit)
                            .font(.system(.callout, design: .rounded).weight(.semibold))
                            .foregroundStyle(Color(hue: 0.10, saturation: 0.60, brightness: 1.0))
                    }
                    Text(ctx.metricCaption)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.48))
                }
                .position(x: cx, y: cy + maxR * 0.62)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(ctx.metricValue)
                        .font(.system(size: 17, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    Text(ctx.metricUnit)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color(hue: 0.10, saturation: 0.60, brightness: 1.0))
                }
                .padding([.leading, .bottom], 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }

            // ── large: item rows at bottom ────────────────────────
            if isLarge {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(height: 0.5)
                        .padding(.horizontal, 14)
                    ForEach(ctx.items.prefix(3)) { item in
                        HStack {
                            Text(item.title)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.82))
                                .lineLimit(1)
                            Spacer()
                            Text(item.subtitle)
                                .font(.system(.footnote, design: .rounded).weight(.semibold))
                                .foregroundStyle(Color(hue: 0.10, saturation: 0.70, brightness: 1.0))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                    }
                }
                .frame(width: W, height: H)
            }

            // ── app name + trend (top bar) ────────────────────────
            HStack(spacing: 4) {
                Text(ctx.appName)
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(.white.opacity(0.38))
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.system(size: 10).weight(.semibold))
                    .foregroundStyle(Color(hue: 0.11, saturation: 0.70, brightness: 1.0))
            }
            .padding(.horizontal, 14)
            .padding(.top, 11)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }
}
