import SwiftUI

/// Faux-voronoi shattered-glass mosaic. Triangulated jitter-grid produces
/// irregular crystal cells; hairline edges, a clear hero zone, and a
/// top-left specular burst give the frozen-glass illusion.
@MainActor
struct VoronoiShatterConcept: WidgetConcept {
    static let id              = "voronoi-shatter"
    static let title           = "Voronoi Shatter"
    static let blurb           = "Shattered-glass crystal mosaic: irregular translucent cells, hairline fractures, crystalline metric core."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(root(ctx: ctx, family: family))
    }

    // MARK: - Root composition

    private func root(ctx: ConceptContext, family: ConceptFamily) -> some View {
        let isLarge = (family == .large)
        let sz      = family.size
        let cells   = shards(in: sz, ctx: ctx, isLarge: isLarge)

        return ZStack {
            // Void ground
            Color(red: 0.03, green: 0.04, blue: 0.08)

            // Subtle angular haze — faux internal refraction
            AngularGradient(
                colors: [ctx.accent.opacity(0.05), ctx.accentSecondary.opacity(0.07),
                         .clear, ctx.accent.opacity(0.03), .clear],
                center: UnitPoint(x: 0.25, y: 0.15)
            )

            // Crystal mosaic
            Canvas { gc, _ in
                for s in cells {
                    gc.fill(s.path, with: .color(s.fill))
                    gc.stroke(s.path, with: .color(s.edge), lineWidth: 0.5)
                }
            }

            if isLarge { largeContent(ctx: ctx, family: family) }
            else       { mediumContent(ctx: ctx, family: family) }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.48), .white.opacity(0.07)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 1
                )
        }
    }

    // MARK: - Content overlays

    private func mediumContent(ctx: ConceptContext, family: ConceptFamily) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(ctx.appName)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ctx.accent)
            }
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(ctx.metricValue)
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text(ctx.metricUnit)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
            }
            Text(ctx.metricCaption)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.42))
                .padding(.top, 2)
            Spacer()
        }
        .padding(16)
    }

    private func largeContent(ctx: ConceptContext, family: ConceptFamily) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(ctx.appName)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 10, weight: .bold))
                    Text(ctx.statusText)
                        .font(.system(.caption2, design: .rounded).weight(.medium))
                }
                .foregroundStyle(ctx.accent)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(ctx.accent.opacity(0.15), in: Capsule())
            }

            Spacer(minLength: 10)

            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(ctx.metricValue)
                    .font(.system(size: 58, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text(ctx.metricUnit)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
            }
            Text(ctx.metricCaption)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.43))
                .padding(.top, 1)

            Spacer(minLength: 16)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1)).frame(height: 3)
                    Capsule()
                        .fill(LinearGradient(colors: [ctx.accent, ctx.accentSecondary],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * ctx.progress, height: 3)
                }
            }
            .frame(height: 3)
            HStack {
                Text(ctx.progressLabel)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.38))
                Spacer()
                Text(String(format: "%.0f%%", ctx.progress * 100))
                    .font(.system(.caption2, design: .monospaced).weight(.semibold))
                    .foregroundStyle(ctx.accent)
            }
            .padding(.top, 4)

            Spacer(minLength: 14)

            VStack(spacing: 0) {
                ForEach(ctx.items.prefix(3)) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.title)
                                .font(.system(.footnote, design: .rounded).weight(.medium))
                                .foregroundStyle(.white.opacity(0.85)).lineLimit(1)
                            Text(item.subtitle)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.37))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.17))
                    }
                    .padding(.vertical, 7)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(.white.opacity(0.07)).frame(height: 0.5)
                    }
                }
            }

            Spacer(minLength: 0)

            Text(ctx.updatedText)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.28))
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Shard generation

    private func shards(in sz: CGSize, ctx: ConceptContext, isLarge: Bool) -> [Shard] {
        let cols = isLarge ? 9 : 8
        let rows = isLarge ? 11 : 6
        var rng  = XSR(seed: UInt64(abs(ctx.countValue) * 17 + 3) ^ UInt64(ctx.progress * 9973))

        let cw = sz.width  / Double(cols - 1)
        let ch = sz.height / Double(rows - 1)

        var grid = [[CGPoint]]()
        for r in 0..<rows {
            var row = [CGPoint]()
            for c in 0..<cols {
                let border = r == 0 || r == rows-1 || c == 0 || c == cols-1
                let jx = border ? 0.0 : (rng.f() - 0.5) * cw * 0.72
                let jy = border ? 0.0 : (rng.f() - 0.5) * ch * 0.72
                row.append(CGPoint(x: Double(c)*cw + jx, y: Double(r)*ch + jy))
            }
            grid.append(row)
        }

        let hx = sz.width  * 0.5
        let hy = isLarge ? sz.height * 0.34 : sz.height * 0.5
        let lx = sz.width  * 0.08     // light source: top-left
        let ly = sz.height * 0.04

        var result = [Shard]()
        result.reserveCapacity((rows-1) * (cols-1) * 2)

        for r in 0..<(rows-1) {
            for c in 0..<(cols-1) {
                let tl = grid[r][c],   tr = grid[r][c+1]
                let bl = grid[r+1][c], br = grid[r+1][c+1]
                for tri in [[tl,tr,bl], [tr,br,bl]] {
                    result.append(shard(pts: tri, hx: hx, hy: hy, lx: lx, ly: ly,
                                        sz: sz, ctx: ctx, rng: &rng))
                }
            }
        }
        return result
    }

    private func shard(pts: [CGPoint], hx: Double, hy: Double,
                       lx: Double, ly: Double,
                       sz: CGSize, ctx: ConceptContext, rng: inout XSR) -> Shard {
        let cx = (pts[0].x + pts[1].x + pts[2].x) / 3
        let cy = (pts[0].y + pts[1].y + pts[2].y) / 3

        let dHero  = hypot(cx - hx, cy - hy)
        let dLight = hypot(cx - lx, cy - ly)
        let dMax   = hypot(sz.width, sz.height)

        let tHero  = min(dHero  / (sz.width * 0.6),   1.0)   // 0 = at hero, 1 = far
        let tLight = max(0.0, 1.0 - dLight / (dMax * 0.48))  // 0 = far, 1 = at light
        let v      = rng.f()
        let angle  = atan2(cy - hy, cx - hx) + .pi            // 0…2π

        var path = Path()
        path.move(to: pts[0])
        path.addLine(to: pts[1])
        path.addLine(to: pts[2])
        path.closeSubpath()

        let fill: Color
        let edgeAlpha: Double

        if tHero < 0.25 {
            // Clear hero zone — near-invisible ice
            fill      = Color.white.opacity(0.03 + v * 0.04 + tLight * 0.06)
            edgeAlpha = 0.10 + v * 0.12
        } else if tLight > 0.52 {
            // Specular burst near light source
            fill      = Color.white.opacity(0.10 + tLight * 0.20 + v * 0.06)
            edgeAlpha = 0.35 + tLight * 0.25
        } else {
            // Chromatic cells: accent / accentSecondary keyed to polar angle + noise
            let alpha    = 0.10 + tHero * 0.22 + v * 0.06
            let useAccent = sin(angle * 1.3 + v * .pi) > 0
            fill      = useAccent
                ? ctx.accent.opacity(alpha)
                : ctx.accentSecondary.opacity(alpha * 0.88)
            edgeAlpha = 0.13 + tHero * 0.18 + v * 0.07
        }

        return Shard(path: path, fill: fill, edge: Color.white.opacity(edgeAlpha))
    }
}

// MARK: - Private value types

private struct Shard {
    let path: Path
    let fill: Color
    let edge: Color
}

/// Xorshift64 — deterministic, value-type PRNG. No global state (Swift 6 safe).
private struct XSR {
    var s: UInt64
    init(seed: UInt64) { s = seed == 0 ? 0x1234_5678_90AB_CDEF : seed }
    mutating func next() -> UInt64 { s ^= s << 13; s ^= s >> 7; s ^= s << 17; return s }
    mutating func f()    -> Double { Double(next() >> 11) / Double(1 << 53) }
}
