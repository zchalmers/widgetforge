import SwiftUI

// Geological strata widget: data-keyed horizontal sediment bands in earthy+accent
// tones with grain texture; a frosted glass core-sample tube frames the hero metric.
@MainActor
struct StratifiedLayersConcept: WidgetConcept {

    static let id               = "stratified-layers"
    static let title            = "Stratified Layers"
    static let blurb            = "Earthy sediment bands sized from live data; a glass core-sample tube frames the hero metric."
    static let preferredScheme: ColorScheme = .light

    // (red, green, blue, base-weight) — r < 0 flags synthetic seams: -1=accent, -2=secondary
    private static let bands: [(r: Double, g: Double, b: Double, w: Double)] = [
        (0.14, 0.09, 0.06, 0.60),   // dark basalt
        (0.56, 0.33, 0.18, 1.10),   // terracotta clay
        (0.78, 0.61, 0.37, 0.75),   // ochre
        (0.91, 0.86, 0.71, 1.35),   // pale chalk  [scales with progress]
        (-1,   0,    0,    0.22),   // teal accent seam
        (0.50, 0.36, 0.22, 0.90),   // mid clay
        (0.82, 0.68, 0.45, 1.60),   // warm sandstone  [scales with items]
        (0.28, 0.19, 0.12, 0.45),   // dark silt
        (-2,   0,    0,    0.16),   // violet seam
        (0.92, 0.88, 0.76, 0.70),   // surface sand
    ]

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(layout(ctx: ctx, family: family))
    }

    // MARK: - Root layout

    private func layout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        let sz    = family.size
        let large = family == .large
        let pad: CGFloat   = large ? 16 : 13
        let tubeW: CGFloat = large ? 130 : 102
        let tubeH: CGFloat = sz.height - (large ? 44 : 26)
        let tubeR: CGFloat = tubeW * 0.22
        let tubeX: CGFloat = large ? sz.width * 0.695 : sz.width * 0.675
        let leftW: CGFloat = tubeX - tubeW * 0.5 - (large ? 10 : 8)

        return ZStack {

            // ── 1. Strata + grain canvas ──────────────────────────────────
            Canvas { gc, csz in
                var wt = Self.bands.map { $0.w }
                wt[3] *= 0.55 + ctx.progress * 0.90
                wt[6] *= 0.50 + Double(ctx.items.count) / 4.0
                wt[4]  = max(0.10, min(0.42, Double(ctx.countValue) / 18.0))
                let total = wt.reduce(0.0, +)

                var yOff: CGFloat = 0
                for (i, b) in Self.bands.enumerated() {
                    let h = CGFloat(wt[i] / total) * csz.height
                    let col: Color = b.r < 0
                        ? (b.r < -1.5 ? ctx.accentSecondary.opacity(0.55)
                                       : ctx.accent.opacity(0.68))
                        : Color(red: b.r, green: b.g, blue: b.b)
                    gc.fill(Path(CGRect(x: 0, y: yOff, width: csz.width, height: h)),
                            with: .color(col))
                    gc.fill(Path(CGRect(x: 0, y: yOff, width: csz.width, height: h * 0.20)),
                            with: .color(Color.white.opacity(0.06)))
                    gc.fill(Path(CGRect(x: 0, y: yOff, width: csz.width, height: 0.8)),
                            with: .color(Color.black.opacity(0.15)))
                    yOff += h
                }
                // Grain — deterministic LCG scatter seeded from data
                var s = UInt64(bitPattern: Int64(ctx.countValue) &* 137 &+ 2357)
                for _ in 0..<280 {
                    s = s &* 6364136223846793005 &+ 1442695040888963407
                    let gx = CGFloat((s >> 33) & 0xFFFF) / 65535.0 * csz.width
                    s = s &* 6364136223846793005 &+ 1442695040888963407
                    let gy = CGFloat((s >> 33) & 0xFFFF) / 65535.0 * csz.height
                    s = s &* 6364136223846793005 &+ 1442695040888963407
                    let al = 0.025 + Double((s >> 40) & 0x3F) / 2200.0
                    gc.fill(Path(CGRect(x: gx, y: gy, width: 1.8, height: 1.8)),
                            with: .color(Color.black.opacity(al)))
                }
            }
            .frame(width: sz.width, height: sz.height)

            // ── 2. Depth vignettes ────────────────────────────────────────
            LinearGradient(colors: [.black.opacity(0.25), .clear],
                           startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.30))
            .blendMode(.multiply)
            .frame(width: sz.width, height: sz.height)

            LinearGradient(colors: [.black.opacity(0.18), .clear],
                           startPoint: .bottom, endPoint: UnitPoint(x: 0.5, y: 0.80))
            .blendMode(.multiply)
            .frame(width: sz.width, height: sz.height)

            // ── 3. Left info panel ────────────────────────────────────────
            VStack(alignment: .leading, spacing: large ? 9 : 5) {
                HStack(spacing: 5) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ctx.accent)
                        .padding(4)
                        .background(Color.white.opacity(0.28), in: Circle())
                    Text(ctx.appName)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.35), radius: 1)
                }
                Spacer(minLength: 0)
                if large {
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(ctx.items) { item in
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.title)
                                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.92))
                                    .shadow(color: .black.opacity(0.30), radius: 1)
                                    .lineLimit(1)
                                Text(item.subtitle)
                                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                                    .foregroundStyle(ctx.accent.opacity(0.90))
                                    .lineLimit(1)
                            }
                        }
                    }
                } else {
                    Text(ctx.statusText)
                        .font(.system(.caption2, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.30), radius: 1)
                        .lineLimit(2)
                }
                Text(ctx.updatedText)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.50))
                    .shadow(color: .black.opacity(0.30), radius: 1)
            }
            .padding(pad)
            .frame(width: leftW, height: sz.height, alignment: .topLeading)
            .position(x: leftW / 2, y: sz.height / 2)

            // ── 4. Core-sample tube ───────────────────────────────────────
            ZStack {
                // Ambient shadow
                RoundedRectangle(cornerRadius: tubeR, style: .continuous)
                    .fill(.black.opacity(0.24))
                    .blur(radius: 9)
                    .offset(y: 5)
                // Frosted interior
                RoundedRectangle(cornerRadius: tubeR, style: .continuous)
                    .fill(Color.white.opacity(0.22))
                // Left-edge specular
                LinearGradient(
                    colors: [.white.opacity(0.32), .white.opacity(0.05), .clear],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: tubeW * 0.35)
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipShape(RoundedRectangle(cornerRadius: tubeR, style: .continuous))

                // Content
                VStack(spacing: large ? 5 : 3) {
                    if large {
                        Capsule()
                            .fill(ctx.accent.opacity(0.28))
                            .frame(width: 26, height: 3)
                        Spacer(minLength: 2)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(ctx.metricValue)
                            .font(.system(size: large ? 42 : 30, weight: .black, design: .rounded))
                            .foregroundStyle(ctx.accent)
                            .shadow(color: .white.opacity(0.55), radius: 2, x: 0, y: 1)
                        Text(ctx.metricUnit)
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(Color(red: 0.25, green: 0.17, blue: 0.10))
                    }
                    Text(ctx.metricCaption)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(Color(red: 0.30, green: 0.20, blue: 0.12).opacity(0.80))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    if large {
                        Spacer(minLength: 8)
                        ZStack {
                            Circle()
                                .stroke(Color.black.opacity(0.08), lineWidth: 4)
                            Circle()
                                .trim(from: 0, to: ctx.progress)
                                .stroke(ctx.accent,
                                        style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                        }
                        .frame(width: 44, height: 44)
                        Text("\(Int(ctx.progress * 100))%")
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundStyle(ctx.accent)
                        Text(ctx.progressLabel)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Color(red: 0.28, green: 0.18, blue: 0.10).opacity(0.72))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                        Spacer(minLength: 8)
                        // Core-sample depth tick marks
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(0..<3) { i in
                                HStack(spacing: 5) {
                                    Rectangle()
                                        .fill(ctx.accent.opacity(0.50))
                                        .frame(width: 12, height: 1.5)
                                    Text(ctx.items[i].title)
                                        .font(.system(size: 8, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color(red: 0.25, green: 0.18, blue: 0.10)
                                            .opacity(0.88))
                                        .lineLimit(1)
                                }
                            }
                        }
                        Spacer(minLength: 6)
                    }
                }
                .frame(width: tubeW - 18)

                // Glass stroke
                RoundedRectangle(cornerRadius: tubeR, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.65), .white.opacity(0.20)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .frame(width: tubeW, height: tubeH)
            .position(x: tubeX, y: sz.height * 0.5)
        }
        .frame(width: sz.width, height: sz.height)
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }
}
