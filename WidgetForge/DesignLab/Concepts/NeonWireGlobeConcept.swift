import SwiftUI

@MainActor
struct NeonWireGlobeConcept: WidgetConcept {

    static let id              = "neon-wire-globe"
    static let title           = "Neon Wire Globe"
    static let blurb           = "Retro-future vector 3D wireframe globe with latitude/longitude neon arcs and orbiting accent dots."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                Color.black
                if family == .medium {
                    mediumContent(ctx: ctx, size: family.size)
                } else {
                    largeContent(ctx: ctx, size: family.size)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }

    // MARK: – Globe Canvas

    private func globeCanvas(ctx: ConceptContext, radius: CGFloat) -> some View {
        let teal   = ctx.accent
        let violet = ctx.accentSecondary
        let prog   = ctx.progress
        let cnt    = ctx.countValue

        return Canvas { gc, sz in
            let cx: CGFloat = sz.width  / 2
            let cy: CGFloat = sz.height / 2
            let R:  CGFloat = radius
            let tilt: CGFloat = 0.36

            // outer sphere silhouette glow
            let sphere = Path(ellipseIn: CGRect(x: cx - R, y: cy - R, width: R * 2, height: R * 2))
            gc.stroke(sphere, with: .color(teal.opacity(0.06)), lineWidth: 26)
            gc.stroke(sphere, with: .color(teal.opacity(0.17)), lineWidth: 11)
            gc.stroke(sphere, with: .color(teal.opacity(0.60)), lineWidth: 1.0)

            // latitude rings
            let lats: [CGFloat] = [-60, -30, 0, 30, 60]
            for lat in lats {
                let rad: CGFloat = lat * .pi / 180
                let yOff = -R * sin(rad)
                let xR   =  R * cos(rad)
                let yR   =  xR * tilt
                let rect = CGRect(x: cx - xR, y: cy + yOff - yR, width: xR * 2, height: yR * 2)
                let ring = Path(ellipseIn: rect)
                let a: Double = lat == 0 ? 0.95 : 0.50
                gc.stroke(ring, with: .color(teal.opacity(a * 0.20)), lineWidth: 6)
                gc.stroke(ring, with: .color(teal.opacity(a * 0.55)), lineWidth: 2)
                gc.stroke(ring, with: .color(teal.opacity(a)),        lineWidth: 0.8)
            }

            // longitude meridians
            let lons: [CGFloat] = [0, 30, 60, 90, 120, 150]
            for lon in lons {
                let rad: CGFloat = lon * .pi / 180
                let xR = R * abs(sin(rad))
                if xR < 2 {
                    let line = Path { p in
                        p.move(to: CGPoint(x: cx, y: cy - R))
                        p.addLine(to: CGPoint(x: cx, y: cy + R))
                    }
                    gc.stroke(line, with: .color(violet.opacity(0.20)), lineWidth: 6)
                    gc.stroke(line, with: .color(violet.opacity(0.50)), lineWidth: 2)
                    gc.stroke(line, with: .color(violet.opacity(0.75)), lineWidth: 0.7)
                } else {
                    let rect  = CGRect(x: cx - xR, y: cy - R, width: xR * 2, height: R * 2)
                    let merid = Path(ellipseIn: rect)
                    gc.stroke(merid, with: .color(violet.opacity(0.18)), lineWidth: 6)
                    gc.stroke(merid, with: .color(violet.opacity(0.46)), lineWidth: 2)
                    gc.stroke(merid, with: .color(violet.opacity(0.70)), lineWidth: 0.7)
                }
            }

            // orbiting accent dots on a flattened elliptical orbit
            let orbitR = R * 1.18
            let nDots  = min(cnt + 2, 8)
            for i in 0 ..< nDots {
                let t  = Double(i) / Double(nDots) * 2 * .pi + prog * .pi
                let dx = cx + orbitR * CGFloat(cos(t))
                let dy = cy + orbitR * 0.38 * CGFloat(sin(t))
                let ds: CGFloat = i == 0 ? 5.5 : 3.5
                let dc = i % 2 == 0 ? teal : violet
                gc.fill(Path(ellipseIn: CGRect(x: dx - ds * 1.8, y: dy - ds * 1.8,
                                               width: ds * 3.6,  height: ds * 3.6)),
                        with: .color(dc.opacity(0.18)))
                gc.fill(Path(ellipseIn: CGRect(x: dx - ds / 2,   y: dy - ds / 2,
                                               width: ds,         height: ds)),
                        with: .color(dc.opacity(0.95)))
            }

            // pole markers
            gc.fill(Path(ellipseIn: CGRect(x: cx - 3, y: cy - R - 3, width: 6, height: 6)),
                    with: .color(teal.opacity(0.90)))
            gc.fill(Path(ellipseIn: CGRect(x: cx - 3, y: cy + R - 3, width: 6, height: 6)),
                    with: .color(violet.opacity(0.90)))
        }
    }

    // MARK: – Shared sub-views

    private func metricBlock(ctx: ConceptContext, large: Bool) -> some View {
        VStack(alignment: .leading, spacing: large ? 4 : 2) {
            Text(ctx.appName.uppercased())
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.40))
                .kerning(1.4)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(ctx.metricValue)
                    .font(.system(size: large ? 52 : 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(ctx.metricUnit)
                    .font(.system(.title3, design: .rounded).weight(.medium))
                    .foregroundStyle(ctx.accent)
            }
            Text(ctx.metricCaption)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.52))
        }
    }

    private func progressBar(ctx: ConceptContext) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.08))
                Capsule()
                    .fill(LinearGradient(colors: [ctx.accent, ctx.accentSecondary],
                                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * CGFloat(ctx.progress))
            }
        }
    }

    // MARK: – Medium layout  360 × 170 — globe left, metric right

    private func mediumContent(ctx: ConceptContext, size: CGSize) -> some View {
        HStack(spacing: 0) {
            globeCanvas(ctx: ctx, radius: 65)
                .frame(width: size.height, height: size.height)

            VStack(alignment: .leading, spacing: 0) {
                metricBlock(ctx: ctx, large: false)
                Spacer(minLength: 4)
                HStack(spacing: 4) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ctx.accent)
                    Text(ctx.statusText)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                }
                progressBar(ctx: ctx).frame(height: 3).padding(.top, 6)
                Text(ctx.updatedText)
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.25))
                    .padding(.top, 4)
            }
            .padding(.leading, 6)
            .padding(.trailing, 18)
            .padding(.vertical, 16)
        }
    }

    // MARK: – Large layout  360 × 376 — header + globe + list

    private func largeContent(ctx: ConceptContext, size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                metricBlock(ctx: ctx, large: true)
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    HStack(spacing: 4) {
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(ctx.accent)
                        Text(ctx.statusText)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.60))
                    }
                    Text("\(ctx.countValue) \(ctx.countCaption)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(ctx.accentSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            globeCanvas(ctx: ctx, radius: 108)
                .frame(width: size.width, height: 208)

            VStack(spacing: 0) {
                ForEach(ctx.items) { item in
                    HStack {
                        Text(item.title)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.white.opacity(0.80))
                            .lineLimit(1)
                        Spacer()
                        Text(item.subtitle)
                            .font(.system(.footnote, design: .rounded).weight(.semibold))
                            .foregroundStyle(ctx.accent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 7)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(.white.opacity(0.07)).frame(height: 1)
                    }
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                progressBar(ctx: ctx).frame(height: 3)
                Text(ctx.updatedText)
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.25))
                    .fixedSize()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
    }
}
