import SwiftUI

// MARK: - LiquidChromeBlobConcept

@MainActor
struct LiquidChromeBlobConcept: WidgetConcept {

    static let id              = "liquid-chrome-blob"
    static let title           = "Liquid Chrome Blob"
    static let blurb           = "Organic blob with angular chrome gradient, specular highlights, and bold mirror type."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(root(ctx: ctx, family: family))
    }

    // MARK: - Root composition

    private func root(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            // Deep-space base
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.10),
                         Color(red: 0.07, green: 0.03, blue: 0.14)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            // Violet depth glow from bottom-left
            RadialGradient(
                colors: [ctx.accentSecondary.opacity(0.24), .clear],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: family.size.height * 1.2
            )
            // Blob shadow for depth
            BlobShape(phase: ctx.progress, family: family)
                .fill(ctx.accentSecondary.opacity(0.30))
                .scaleEffect(1.12)
                .offset(x: 18, y: 14)
                .blur(radius: 30)
            // Main chrome blob with angular gradient
            BlobShape(phase: ctx.progress, family: family)
                .fill(AngularGradient(
                    stops: chromeStops(a: ctx.accent, b: ctx.accentSecondary),
                    center: .center,
                    angle: .degrees(14)
                ))
                .overlay(
                    // Specular highlight: bright streak top-left
                    BlobShape(phase: ctx.progress, family: family)
                        .fill(LinearGradient(
                            colors: [.white.opacity(0.68), .clear],
                            startPoint: UnitPoint(x: 0.08, y: 0.05),
                            endPoint: UnitPoint(x: 0.54, y: 0.52)
                        ))
                        .blendMode(.screen)
                )
            // Caustic reflection lines
            Canvas { gc, size in
                for i in 0..<20 {
                    let t = Double(i) / 19.0
                    let x0 = size.width * (-0.06 + t * 1.14)
                    var line = Path()
                    line.move(to: CGPoint(x: x0, y: 0))
                    line.addLine(to: CGPoint(x: x0 + size.height * 0.20, y: size.height))
                    gc.stroke(line,
                              with: .color(.white.opacity(0.022 + sin(t * .pi) * 0.028)),
                              style: StrokeStyle(lineWidth: 0.8))
                }
            }
            .blendMode(.screen)
            // Text + data content
            contentLayer(ctx: ctx, family: family)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Chrome gradient stops

    private func chromeStops(a: Color, b: Color) -> [Gradient.Stop] {
        [
            .init(color: .white.opacity(0.94),  location: 0.00),
            .init(color: Color(white: 0.72),     location: 0.10),
            .init(color: a.opacity(0.88),        location: 0.22),
            .init(color: Color(white: 0.36),     location: 0.35),
            .init(color: Color(white: 0.06),     location: 0.48),
            .init(color: b.opacity(0.72),        location: 0.62),
            .init(color: Color(white: 0.20),     location: 0.76),
            .init(color: Color(white: 0.62),     location: 0.88),
            .init(color: .white.opacity(0.88),   location: 1.00),
        ]
    }

    // MARK: - Content layer

    @ViewBuilder
    private func contentLayer(ctx: ConceptContext, family: ConceptFamily) -> some View {
        let vpad: CGFloat = family == .large ? 22 : 16
        let items = Array(ctx.items.prefix(3).enumerated())

        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack {
                Text(ctx.appName)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.68))
                    .textCase(.uppercase)
                    .tracking(1.4)
                Spacer()
                Label(ctx.statusText, systemImage: ctx.trend.symbol)
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .foregroundStyle(ctx.accent)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(.white.opacity(0.09), in: Capsule())
            }

            Spacer(minLength: 0)

            // Hero metric + mirror reflection
            VStack(alignment: .leading, spacing: 0) {
                let heroSize: CGFloat = family == .large ? 70 : 50
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(ctx.metricValue)
                        .font(.system(size: heroSize, design: .rounded).weight(.black))
                        .foregroundStyle(.white)
                    Text(ctx.metricUnit)
                        .font(.system(.title2, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.58))
                }
                // Mirror reflection — flipped, gradient-faded
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(ctx.metricValue)
                        .font(.system(size: heroSize, design: .rounded).weight(.black))
                        .foregroundStyle(LinearGradient(
                            colors: [.white.opacity(0.22), .clear],
                            startPoint: .top, endPoint: .bottom
                        ))
                    Text(ctx.metricUnit)
                        .font(.system(.title2, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.08))
                }
                .scaleEffect(y: -1, anchor: .top)
                .frame(height: family == .large ? 26 : 18)
                .clipped()
                .blendMode(.screen)

                Text(ctx.metricCaption)
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundStyle(.white.opacity(0.52))
                    .padding(.top, 6)
            }

            Spacer(minLength: 0)

            // Large-only: progress arc + item rows
            if family == .large {
                Canvas { gc, size in
                    let cx = size.width / 2
                    let cy = size.height * 0.52
                    let r: CGFloat = min(size.width, size.height) * 0.36
                    var track = Path()
                    track.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                                 startAngle: .degrees(150), endAngle: .degrees(390),
                                 clockwise: false)
                    gc.stroke(track, with: .color(.white.opacity(0.10)),
                              style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    let sweep = 150.0 + 240.0 * ctx.progress
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                               startAngle: .degrees(150), endAngle: .degrees(sweep),
                               clockwise: false)
                    gc.stroke(arc, with: .linearGradient(
                        Gradient(colors: [ctx.accent, ctx.accentSecondary]),
                        startPoint: CGPoint(x: cx - r, y: cy),
                        endPoint: CGPoint(x: cx + r, y: cy)
                    ), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    var dot = Path()
                    dot.addEllipse(in: CGRect(x: cx - 3, y: cy - 3, width: 6, height: 6))
                    gc.fill(dot, with: .color(ctx.accent.opacity(0.9)))
                }
                .frame(height: 52)

                VStack(spacing: 0) {
                    ForEach(items, id: \.offset) { pair in
                        HStack {
                            Text(pair.element.title)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.82))
                                .lineLimit(1)
                            Spacer()
                            Text(pair.element.subtitle)
                                .font(.system(.footnote, design: .rounded).weight(.semibold))
                                .foregroundStyle(ctx.accent)
                        }
                        .padding(.vertical, 7)
                        if pair.offset < items.count - 1 {
                            Rectangle()
                                .fill(.white.opacity(0.09))
                                .frame(height: 0.5)
                        }
                    }
                }
            }

            // Footer
            Text(ctx.updatedText)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.white.opacity(0.32))
                .padding(.top, family == .large ? 8 : 4)
        }
        .padding(vpad)
    }
}

// MARK: - BlobShape (private helper)

private struct BlobShape: Shape {
    let phase: Double    // 0…1, modulates per-point radius
    let family: ConceptFamily

    func path(in rect: CGRect) -> Path {
        // Center offset slightly right; text block sits on the left
        let cx = rect.midX + rect.width * 0.12
        let cy = rect.midY
        let rx = rect.width  * (family == .large ? 0.50 : 0.44)
        let ry = rect.height * (family == .large ? 0.47 : 0.52)

        // 8 anchor points: (xMul, yMul) pairs at 0°, 45°, … 315°
        let radii: [(xm: Double, ym: Double)] = [
            (1.00,                   1.00),
            (1.00 + phase * 0.10,    0.82),
            (0.80,                   1.00),
            (0.88 + phase * 0.08,    1.06),
            (1.00,                   1.00),
            (0.94,                   0.86 + phase * 0.10),
            (0.84 + phase * 0.06,    1.00),
            (1.00,                   0.90),
        ]
        let n = radii.count
        var pts: [CGPoint] = (0..<n).map { i in
            let angle = Double(i) * (2.0 * .pi / Double(n))
            return CGPoint(
                x: cx + cos(angle) * rx * radii[i].xm,
                y: cy + sin(angle) * ry * radii[i].ym
            )
        }

        // Catmull-Rom → cubic Bezier  (tension k ≈ 0.30)
        let k = 0.30
        var path = Path()
        path.move(to: pts[0])
        for i in 0..<n {
            let p0 = pts[(i - 1 + n) % n]
            let p1 = pts[i]
            let p2 = pts[(i + 1) % n]
            let p3 = pts[(i + 2) % n]
            let cp1 = CGPoint(x: p1.x + k * (p2.x - p0.x),
                              y: p1.y + k * (p2.y - p0.y))
            let cp2 = CGPoint(x: p2.x - k * (p3.x - p1.x),
                              y: p2.y - k * (p3.y - p1.y))
            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }
        path.closeSubpath()
        return path
    }
}
