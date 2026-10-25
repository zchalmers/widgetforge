import SwiftUI

@MainActor
struct ParticleConstellationConcept: WidgetConcept {
    static let id             = "particle-constellation"
    static let title          = "Particle Constellation"
    static let blurb          = "Data becomes a star field — nodes linked by proximity, the metric as the brightest star."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                spaceBackground(ctx: ctx)
                Canvas { gc, size in constellation(gc, size, ctx, family) }
                overlay(ctx: ctx, family: family)
            }
            .frame(width: family.size.width, height: family.size.height)
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }

    // MARK: - Background

    private func spaceBackground(ctx: ConceptContext) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hue: 0.63, saturation: 0.55, brightness: 0.07),
                         Color(hue: 0.76, saturation: 0.45, brightness: 0.03)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            RadialGradient(colors: [ctx.accent.opacity(0.13), .clear],
                           center: .init(x: 0.28, y: 0.18),
                           startRadius: 0, endRadius: 150)
            RadialGradient(colors: [ctx.accentSecondary.opacity(0.09), .clear],
                           center: .init(x: 0.78, y: 0.82),
                           startRadius: 0, endRadius: 110)
        }
    }

    // MARK: - Text overlay

    private func overlay(ctx: ConceptContext, family: ConceptFamily) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(ctx.appName)
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.45))
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ctx.accent.opacity(0.9))
            }
            .padding(.horizontal, 16)
            .padding(.top, 13)

            Spacer()

            // Hero metric — centred; glow applied via shadow so it halos the type
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(ctx.metricValue)
                    .font(.system(size: family == .large ? 70 : 48,
                                  weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: ctx.accent.opacity(0.90), radius: 14)
                    .shadow(color: ctx.accent.opacity(0.40), radius: 30)
                VStack(alignment: .leading, spacing: 1) {
                    Text(ctx.metricUnit)
                        .font(.system(size: family == .large ? 21 : 15,
                                      weight: .semibold, design: .rounded))
                        .foregroundStyle(ctx.accent)
                    Text(ctx.metricCaption)
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(.white.opacity(0.38))
                }
                .padding(.bottom, family == .large ? 10 : 6)
            }
            .frame(maxWidth: .infinity)

            if family == .large {
                Spacer()

                // Progress band
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(ctx.progressLabel)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.38))
                        Spacer()
                        Text("\(Int(ctx.progress * 100))%")
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .foregroundStyle(ctx.accent.opacity(0.85))
                    }
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.07)).frame(height: 2)
                            Capsule()
                                .fill(LinearGradient(colors: [ctx.accent, ctx.accentSecondary],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: g.size.width * ctx.progress, height: 2)
                        }
                    }
                    .frame(height: 2)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

                // Items list
                VStack(spacing: 0) {
                    ForEach(ctx.items.prefix(4)) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(ctx.accentSecondary.opacity(0.6))
                                .frame(width: 3.5, height: 3.5)
                            Text(item.title)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.72))
                                .lineLimit(1)
                            Spacer()
                            Text(item.subtitle)
                                .font(.system(.caption2, design: .rounded).weight(.semibold))
                                .foregroundStyle(.white.opacity(0.38))
                        }
                        .padding(.vertical, 7)
                        .padding(.horizontal, 16)
                    }
                }
                .background(.white.opacity(0.028))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(.horizontal, 8)
            }

            Spacer(minLength: 0)

            HStack {
                Spacer()
                Text(ctx.updatedText)
                    .font(.system(size: 8, design: .rounded))
                    .foregroundStyle(.white.opacity(0.22))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
    }

    // MARK: - Canvas: star field + constellation lines

    private func constellation(_ gc: GraphicsContext, _ size: CGSize,
                                _ ctx: ConceptContext, _ family: ConceptFamily) {
        // Deterministic LCG seeded from data values
        var s: UInt64 = UInt64(bitPattern: Int64(ctx.countValue) * 31337 + 99991)
        func rng() -> Double {
            s = s &* 6364136223846793005 &+ 1442695040888963407
            return Double(s >> 33) / Double(1 << 31)
        }

        let n        = family == .large ? 54 : 28
        let cx       = size.width  * 0.50
        let cy       = size.height * 0.44
        let exclude  = family == .large ? 70.0 : 50.0
        let linkDist = size.width * 0.23

        // Build stars — skip the hero exclusion zone
        var stars: [(pos: CGPoint, bright: Double, teal: Bool)] = []
        for _ in 0..<n {
            var pt = CGPoint.zero
            for _ in 0..<8 {
                pt = CGPoint(x: rng() * size.width, y: rng() * size.height)
                if hypot(pt.x - cx, pt.y - cy) >= exclude { break }
            }
            stars.append((pt, rng() * 0.65 + 0.2, rng() > 0.42))
        }

        // Constellation lines — opacity falls off with distance
        let lineBase = Color(hue: 0.50, saturation: 0.75, brightness: 0.9)
        for i in 0..<stars.count {
            for j in (i+1)..<stars.count {
                let d = hypot(stars[i].pos.x - stars[j].pos.x,
                              stars[i].pos.y - stars[j].pos.y)
                guard d < linkDist else { continue }
                var p = Path()
                p.move(to: stars[i].pos)
                p.addLine(to: stars[j].pos)
                gc.stroke(p,
                          with: .color(lineBase.opacity((1 - d / linkDist) * 0.20)),
                          lineWidth: 0.55)
            }
        }

        // Stars — outer glow + mid ring + bright core
        for star in stars {
            let hue = star.teal ? 0.50 : 0.75
            let col = Color(hue: hue, saturation: 0.65, brightness: 1.0)
            let gr  = star.bright * 9 + 3
            let mr  = star.bright * 3.5 + 1
            gc.fill(Path(ellipseIn: .init(x: star.pos.x-gr, y: star.pos.y-gr,
                                          width: gr*2, height: gr*2)),
                    with: .color(col.opacity(star.bright * 0.11)))
            gc.fill(Path(ellipseIn: .init(x: star.pos.x-mr, y: star.pos.y-mr,
                                          width: mr*2, height: mr*2)),
                    with: .color(col.opacity(star.bright * 0.55)))
            gc.fill(Path(ellipseIn: .init(x: star.pos.x-0.9, y: star.pos.y-0.9,
                                          width: 1.8, height: 1.8)),
                    with: .color(Color.white.opacity(star.bright * 0.88)))
        }

        // Hero glow — concentric rings behind the metric number
        let heroCol = Color(hue: 0.50, saturation: 0.45, brightness: 1.0)
        for (r, a): (Double, Double) in [(58, 0.03), (36, 0.07), (21, 0.13), (11, 0.22), (4.5, 0.48)] {
            gc.fill(Path(ellipseIn: .init(x: cx-r, y: cy-r, width: r*2, height: r*2)),
                    with: .color(heroCol.opacity(a)))
        }
    }
}
