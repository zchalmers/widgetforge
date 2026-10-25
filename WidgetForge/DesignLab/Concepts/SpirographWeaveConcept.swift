import SwiftUI

// MARK: - Concept

@MainActor
struct SpirographWeaveConcept: WidgetConcept {
    static let id = "spirograph-weave"
    static let title = "Spirograph Weave"
    static let blurb = "Intricate parametric spirograph curves seeded by data, woven in accent gradients over dark."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(SpiroLayout(ctx: ctx, family: family))
    }
}

// MARK: - Layout

private struct SpiroLayout: View {
    let ctx: ConceptContext
    let family: ConceptFamily

    private var isLarge: Bool { family == .large }
    private var sz: CGSize { family.size }
    private var spiroCY: CGFloat { isLarge ? sz.height * 0.39 : sz.height * 0.50 }

    var body: some View {
        ZStack {
            // ── Background ───────────────────────────────────────────────────
            Color(red: 0.03, green: 0.03, blue: 0.09)
            RadialGradient(
                colors: [ctx.accentSecondary.opacity(0.22), ctx.accent.opacity(0.10), .clear],
                center: UnitPoint(x: 0.5, y: spiroCY / sz.height),
                startRadius: 12,
                endRadius: sz.width * 0.60
            )
            RadialGradient(          // edge vignette
                colors: [.clear, .black.opacity(0.55)],
                center: .center,
                startRadius: sz.width * 0.28,
                endRadius: sz.width * 0.78
            )

            // ── Spirograph weave (sharp pass + blurred glow pass) ────────────
            SpiroCanvas(ctx: ctx, family: family)
                .blendMode(.screen)
            SpiroCanvas(ctx: ctx, family: family)
                .opacity(0.30)
                .blur(radius: 3)
                .blendMode(.screen)

            // ── Top header ───────────────────────────────────────────────────
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ctx.appName)
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.75))
                        HStack(spacing: 3) {
                            Image(systemName: ctx.trend.symbol)
                                .font(.system(size: 9, weight: .bold))
                            Text(ctx.statusText)
                                .font(.system(.caption2, design: .rounded))
                        }
                        .foregroundStyle(ctx.accent)
                    }
                    Spacer()
                    progressRing
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                Spacer()
            }

            // ── Hero metric — calm center of the weave ───────────────────────
            metricPill
                .position(x: sz.width / 2, y: spiroCY)

            // ── Large: item list at bottom ───────────────────────────────────
            if isLarge {
                VStack(spacing: 0) {
                    Spacer()
                    itemsList
                }
            }
        }
        .frame(width: sz.width, height: sz.height)
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous)
                .stroke(.white.opacity(0.09), lineWidth: 0.5)
        )
    }

    // MARK: Sub-views

    private var progressRing: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.14), lineWidth: 2)
            Circle()
                .trim(from: 0, to: ctx.progress)
                .stroke(
                    LinearGradient(colors: [ctx.accent, ctx.accentSecondary],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(ctx.progress * 100))%")
                .font(.system(size: 7, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(width: 30, height: 30)
    }

    private var metricPill: some View {
        VStack(spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(ctx.metricValue)
                    .font(.system(size: isLarge ? 48 : 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(ctx.metricUnit)
                    .font(.system(.callout, design: .rounded).weight(.medium))
                    .foregroundStyle(ctx.accent)
            }
            Text(ctx.metricCaption)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.50))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.black.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ctx.accent.opacity(0.22), lineWidth: 0.8)
                )
        )
    }

    private var itemsList: some View {
        let items = Array(ctx.items.prefix(4))
        return VStack(spacing: 0) {
            LinearGradient(colors: [.clear, ctx.accentSecondary.opacity(0.12)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 18)
            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { idx in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(idx % 2 == 0 ? ctx.accent : ctx.accentSecondary)
                            .frame(width: 4, height: 4)
                        Text(items[idx].title)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(1)
                        Spacer()
                        Text(items[idx].subtitle)
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                            .foregroundStyle(idx % 2 == 0 ? ctx.accent : ctx.accentSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    if idx < items.count - 1 {
                        Rectangle()
                            .fill(.white.opacity(0.06))
                            .frame(height: 0.5)
                            .padding(.leading, 26)
                    }
                }
            }
            .background(.black.opacity(0.40))
        }
    }
}

// MARK: - Spirograph Canvas

private struct SpiroCanvas: View {
    let ctx: ConceptContext
    let family: ConceptFamily

    var body: some View {
        let isLarge = family == .large
        Canvas { gc, size in
            let cx = size.width / 2
            let cy: CGFloat = isLarge ? size.height * 0.39 : size.height * 0.50
            let base = min(size.width, isLarge ? size.height * 0.78 : size.height) * 0.42
            let n   = CGFloat(ctx.countValue)                        // 7
            let pr  = CGFloat(ctx.progress)                          // 0.62
            let mv  = CGFloat(Double(ctx.metricValue) ?? 4.2)        // 4.2

            // C1 — outer accent: n-petal hypotrochoid
            let p1 = spiroPath(cx: cx, cy: cy, R: base,
                               r: base / n, d: base * pr * 0.88,
                               loops: Int(n), steps: 1500)
            gc.stroke(p1, with: .color(ctx.accent.opacity(0.88)), lineWidth: 1.3)

            // C2 — violet weave: shifted ratio
            let r2 = base * 0.76 / max(n + mv * 0.35, 2)
            let p2 = spiroPath(cx: cx, cy: cy, R: base * 0.76,
                               r: r2, d: base * 0.54, loops: 4, steps: 1500)
            gc.stroke(p2, with: .color(ctx.accentSecondary.opacity(0.82)), lineWidth: 1.1)

            // C3 — inner accent lace
            let ni = max(n - 2, 2)
            let p3 = spiroPath(cx: cx, cy: cy, R: base * 0.56,
                               r: base * 0.56 / ni, d: base * 0.40,
                               loops: Int(ni), steps: 1100)
            gc.stroke(p3, with: .color(ctx.accent.opacity(0.46)), lineWidth: 0.85)

            // C4 — wide secondary halo
            let p4 = spiroPath(cx: cx, cy: cy, R: base * 0.93,
                               r: base * 0.93 / (n * 0.60), d: base * 0.72,
                               loops: 3, steps: 1700)
            gc.stroke(p4, with: .color(ctx.accentSecondary.opacity(0.26)), lineWidth: 0.7)

            if isLarge {
                // C5 — 3:5 Lissajous dashboard
                let p5 = lissajousPath(cx: cx, cy: cy, A: base * 0.68, B: base * 0.40,
                                       fA: 3, fB: 5, delta: pr * .pi, steps: 900)
                gc.stroke(p5, with: .color(ctx.accent.opacity(0.22)), lineWidth: 0.6)

                // C6 — epitrochoid corona
                let p6 = epitrochoidPath(cx: cx, cy: cy, R: base * 0.48,
                                         r: base * 0.48 / (n + 1), d: base * 0.58,
                                         loops: Int(n) + 1, steps: 1200)
                gc.stroke(p6, with: .color(ctx.accentSecondary.opacity(0.20)), lineWidth: 0.6)
            }
        }
    }
}

// MARK: - Parametric Helpers

private func spiroPath(cx: CGFloat, cy: CGFloat,
                       R: CGFloat, r: CGFloat, d: CGFloat,
                       loops: Int, steps: Int) -> Path {
    var path = Path()
    let rs   = max(abs(r), 0.5)
    let Rr   = R - rs
    let k    = Rr / rs
    let tMax = CGFloat(max(loops, 1)) * 2 * .pi
    for i in 0 ... steps {
        let t = tMax * CGFloat(i) / CGFloat(steps)
        let x = cx + Rr * cos(t) + d * cos(k * t)
        let y = cy + Rr * sin(t) - d * sin(k * t)
        if i == 0 { path.move(to: .init(x: x, y: y)) }
        else       { path.addLine(to: .init(x: x, y: y)) }
    }
    return path
}

private func epitrochoidPath(cx: CGFloat, cy: CGFloat,
                              R: CGFloat, r: CGFloat, d: CGFloat,
                              loops: Int, steps: Int) -> Path {
    var path = Path()
    let rs   = max(abs(r), 0.5)
    let Rr   = R + rs
    let k    = Rr / rs
    let tMax = CGFloat(max(loops, 1)) * 2 * .pi
    for i in 0 ... steps {
        let t = tMax * CGFloat(i) / CGFloat(steps)
        let x = cx + Rr * cos(t) - d * cos(k * t)
        let y = cy + Rr * sin(t) - d * sin(k * t)
        if i == 0 { path.move(to: .init(x: x, y: y)) }
        else       { path.addLine(to: .init(x: x, y: y)) }
    }
    return path
}

private func lissajousPath(cx: CGFloat, cy: CGFloat,
                            A: CGFloat, B: CGFloat,
                            fA: CGFloat, fB: CGFloat,
                            delta: CGFloat, steps: Int) -> Path {
    var path = Path()
    let tMax = 2 * CGFloat.pi          // integer fA:fB closes in one [0, 2π] sweep
    for i in 0 ... steps {
        let t = tMax * CGFloat(i) / CGFloat(steps)
        let x = cx + A * sin(fA * t + delta)
        let y = cy + B * sin(fB * t)
        if i == 0 { path.move(to: .init(x: x, y: y)) }
        else       { path.addLine(to: .init(x: x, y: y)) }
    }
    return path
}
