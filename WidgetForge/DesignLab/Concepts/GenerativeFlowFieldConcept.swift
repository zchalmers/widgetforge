import SwiftUI

// File-scope pure function — no actor affinity, safe inside Canvas closures.
private func wfFieldAngle(_ nx: Double, _ ny: Double) -> Double {
    sin(nx * 4.2 + 0.50) * cos(ny * 3.7 + 1.10) * Double.pi * 1.3
        + cos(nx * 2.1 - ny * 1.90) * 0.60
}

@MainActor
struct GenerativeFlowFieldConcept: WidgetConcept {
    static let id              = "gen-flow-field"
    static let title           = "Vector Flow Field"
    static let blurb           = "~150 curved streamlines following a sine/cos field, hero metric knocked out on top."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        let isMedium = (family == .medium)
        let sz       = family.size
        let cr       = family.cornerRadius

        // Captured as Sendable values for Canvas closures.
        let accent    = ctx.accent
        let secondary = ctx.accentSecondary
        let barWidth  = sz.width - 36.0   // 18 pt padding each side

        let view = ZStack(alignment: .topLeading) {

            // ── 1. Deep background ──────────────────────────────────────
            LinearGradient(
                colors: [Color(white: 0.03),
                         Color(white: 0.07),
                         secondary.opacity(0.09)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            // ── 2. Flow-field canvas ────────────────────────────────────
            Canvas { gc, csz in
                let cols  = isMedium ? 10 : 13
                let rows  = isMedium ?  9 : 14
                let steps = isMedium ? 11 : 15
                let step  = csz.width * 0.036

                for row in 0 ..< rows {
                    for col in 0 ..< cols {
                        let jx  = sin(Double(row * 7  + col * 13)) * 0.38
                        let jy  = cos(Double(col * 11 + row *  5)) * 0.38
                        let nx0 = (Double(col) + 0.5 + jx) / Double(cols)
                        let ny0 = (Double(row) + 0.5 + jy) / Double(rows)

                        var x = nx0 * csz.width
                        var y = ny0 * csz.height
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: y))

                        for _ in 0 ..< steps {
                            let angle = wfFieldAngle(x / csz.width, y / csz.height)
                            x += cos(angle) * step
                            y += sin(angle) * step
                            guard x > -step, x < csz.width  + step,
                                  y > -step, y < csz.height + step else { break }
                            path.addLine(to: CGPoint(x: x, y: y))
                        }

                        let t       = Double(row * cols + col) / Double(max(rows * cols - 1, 1))
                        let hero    = (row + col) % 5 == 0
                        let opacity = hero ? 0.82 : 0.26
                        let lw: CGFloat = hero ? 1.3 : 0.65

                        let grad = Gradient(stops: [
                            .init(color: accent.opacity(opacity * 1.1),                 location: 0.0),
                            .init(color: secondary.opacity(opacity * (0.35 + t * 0.65)), location: 1.0)
                        ])
                        gc.stroke(
                            path,
                            with: .linearGradient(
                                grad,
                                startPoint: CGPoint(x: nx0 * csz.width,  y: ny0 * csz.height),
                                endPoint:   CGPoint(x: x,                 y: y)
                            ),
                            lineWidth: lw
                        )
                    }
                }
            }
            .blendMode(.screen)

            // ── 3. Radial vignette ──────────────────────────────────────
            RadialGradient(
                colors: [.clear, Color(white: 0.0, opacity: 0.68)],
                center: .center,
                startRadius: sz.width * 0.14,
                endRadius:   sz.width * 0.74
            )

            // ── 4. Bottom legibility scrim ──────────────────────────────
            LinearGradient(
                colors: [.clear, Color(white: 0.0, opacity: isMedium ? 0.88 : 0.82)],
                startPoint: UnitPoint(x: 0, y: isMedium ? 0.30 : 0.22),
                endPoint: .bottom
            )

            // ── 5. Content ──────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 0) {

                // Header row
                HStack {
                    Text(ctx.appName)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(accent)
                }
                .padding(.bottom, isMedium ? 8 : 14)

                // Hero metric
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(ctx.metricValue)
                        .font(.system(size: isMedium ? 46 : 68,
                                      weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: accent.opacity(0.70), radius: 16, x: 0, y: 0)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(ctx.metricUnit)
                            .font(.system(size: isMedium ? 17 : 24,
                                          weight: .semibold, design: .rounded))
                            .foregroundStyle(accent)
                        if isMedium {
                            Text(ctx.metricCaption)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.50))
                                .lineLimit(1)
                        }
                    }
                    .offset(y: isMedium ? -2 : -4)
                }
                .padding(.bottom, isMedium ? 0 : 4)

                if !isMedium {
                    Text(ctx.metricCaption)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.52))
                        .padding(.bottom, 16)

                    // Progress bar
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(ctx.progressLabel)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.50))
                            Spacer()
                            Text("\(Int(ctx.progress * 100))%")
                                .font(.system(.caption2, design: .rounded).weight(.bold))
                                .foregroundStyle(accent)
                        }
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.10))
                                .frame(height: 4)
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [accent, secondary],
                                    startPoint: .leading, endPoint: .trailing))
                                .frame(width: max(4, barWidth * ctx.progress), height: 4)
                                .shadow(color: accent.opacity(0.55), radius: 4, x: 0, y: 0)
                        }
                        .frame(width: barWidth)
                    }
                    .padding(.bottom, 14)

                    // Items list
                    ForEach(ctx.items.prefix(3)) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(accent.opacity(0.65))
                                .frame(width: 5, height: 5)
                            Text(item.title)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.82))
                                .lineLimit(1)
                            Spacer()
                            Text(item.subtitle)
                                .font(.system(.footnote, design: .monospaced).weight(.semibold))
                                .foregroundStyle(secondary.opacity(0.90))
                        }
                        .padding(.vertical, 4)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(.white.opacity(0.07))
                                .frame(height: 0.5)
                        }
                    }
                }

                Spacer(minLength: 0)

                // Footer
                HStack {
                    Circle()
                        .fill(accent)
                        .frame(width: 5, height: 5)
                    Text(ctx.statusText)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(accent.opacity(0.88))
                    Spacer()
                    Text(ctx.updatedText)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.30))
                }
            }
            .padding(isMedium ? 14 : 18)
        }
        .frame(width: sz.width, height: sz.height)
        .clipShape(RoundedRectangle(cornerRadius: cr, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cr, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [accent.opacity(0.45), secondary.opacity(0.20)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )

        return AnyView(view)
    }
}
