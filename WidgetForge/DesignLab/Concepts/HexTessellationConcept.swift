import SwiftUI

@MainActor
struct HexTessellationConcept: WidgetConcept {
    static let id = "hex-tessellation"
    static let title = "Hex Tessellation Heatmap"
    static let blurb = "Generative honeycomb where hex luminance maps a radial heat field; accent cluster crowns the hot zone, hero metric knocked out above."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        let isLarge = family == .large
        let hexR: CGFloat = isLarge ? 19.0 : 15.0
        let progress = CGFloat(ctx.progress)
        let accent = ctx.accent
        let accentSecondary = ctx.accentSecondary

        return AnyView(
            ZStack {
                Color(red: 0.04, green: 0.05, blue: 0.14)

                Canvas { gc, size in
                    let sqrt3: CGFloat = 1.73205
                    let colStep = hexR * sqrt3
                    let rowStep = hexR * 1.5
                    let hotX = size.width * (0.20 + progress * 0.55)
                    let hotY = size.height * 0.42
                    let cols = Int(size.width / colStep) + 3
                    let rows = Int(size.height / rowStep) + 3

                    for row in 0..<rows {
                        for col in 0..<cols {
                            let cx = CGFloat(col) * colStep
                                + (row % 2 == 1 ? colStep * 0.5 : 0.0)
                                - colStep * 0.5
                            let cy = CGFloat(row) * rowStep - rowStep * 0.5

                            let dx = (cx - hotX) / size.width
                            let dy = (cy - hotY) / size.height
                            let dist = sqrt(dx * dx + dy * dy)
                            let wave = sin(cx * 0.055 + cy * 0.044) * 0.13
                                     + cos(cx * 0.038 - cy * 0.070) * 0.09
                            let heat = max(0.0, min(1.0, 1.0 - dist * 1.65 + wave))

                            let inner = hexR - 1.3
                            var path = Path()
                            for i in 0..<6 {
                                let angle = CGFloat(i) * .pi / 3.0 + .pi / 6.0
                                let pt = CGPoint(x: cx + inner * cos(angle),
                                                 y: cy + inner * sin(angle))
                                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
                            }
                            path.closeSubpath()

                            let fill: Color
                            if heat < 0.20 {
                                let t = heat / 0.20
                                fill = Color(red: 0.05, green: 0.06 + 0.07 * t, blue: 0.16 + 0.20 * t)
                                    .opacity(0.50 + 0.35 * t)
                            } else if heat < 0.50 {
                                let t = (heat - 0.20) / 0.30
                                fill = Color(red: 0.01, green: 0.13 + 0.30 * t, blue: 0.36 + 0.22 * t)
                            } else if heat < 0.77 {
                                let t = (heat - 0.50) / 0.27
                                fill = Color(red: 0.01 + 0.04 * t, green: 0.43 + 0.30 * t, blue: 0.58 + 0.06 * t)
                            } else {
                                let t = (heat - 0.77) / 0.23
                                fill = accent.opacity(0.60 + 0.40 * t)
                            }

                            gc.fill(path, with: .color(fill))
                            if heat > 0.55 {
                                gc.stroke(path,
                                          with: .color(.white.opacity(0.06 + heat * 0.10)),
                                          lineWidth: 0.5)
                            }
                        }
                    }
                }

                RadialGradient(
                    colors: [.clear, .black.opacity(0.65)],
                    center: .center,
                    startRadius: isLarge ? 70 : 45,
                    endRadius: isLarge ? 250 : 145
                )

                VStack(spacing: 0) {
                    // Header bar
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(ctx.appName.uppercased())
                                .font(.system(size: 9, design: .rounded).weight(.semibold))
                                .foregroundStyle(.white.opacity(0.50))
                                .tracking(1.5)
                            Text(ctx.statusText)
                                .font(.system(size: 10, design: .rounded).weight(.medium))
                                .foregroundStyle(accent.opacity(0.85))
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: ctx.trend.symbol)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(accent)
                            Text("\(ctx.countValue)")
                                .font(.system(.caption2, design: .rounded).weight(.bold))
                                .foregroundStyle(.white.opacity(0.70))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.09))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, isLarge ? 20 : 16)
                    .padding(.top, isLarge ? 18 : 13)

                    Spacer()

                    // Hero metric knockout
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text(ctx.metricValue)
                                .font(.system(size: isLarge ? 68 : 48, design: .rounded).weight(.bold))
                                .foregroundStyle(.white)
                                .shadow(color: accent.opacity(0.60), radius: 18, x: 0, y: 0)
                            Text(ctx.metricUnit)
                                .font(.system(isLarge ? .title2 : .title3, design: .rounded).weight(.medium))
                                .foregroundStyle(.white.opacity(0.72))
                                .offset(y: isLarge ? -6 : -4)
                        }
                        Text(ctx.metricCaption)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.55))
                            .tracking(0.4)
                    }
                    .padding(.vertical, isLarge ? 14 : 10)
                    .padding(.horizontal, 30)
                    .background {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.black.opacity(0.48))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [accent.opacity(0.65), accentSecondary.opacity(0.30)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    }

                    Spacer()

                    if isLarge {
                        VStack(spacing: 0) {
                            HStack {
                                Text(ctx.progressLabel.uppercased())
                                    .font(.system(size: 9, design: .rounded).weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.45))
                                    .tracking(1.0)
                                Spacer()
                                Text("\(Int(progress * 100))%")
                                    .font(.system(.caption2, design: .rounded).weight(.bold))
                                    .foregroundStyle(accent)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                            .padding(.bottom, 6)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(.white.opacity(0.08)).frame(height: 2)
                                    Capsule()
                                        .fill(LinearGradient(
                                            colors: [accent, accentSecondary],
                                            startPoint: .leading, endPoint: .trailing
                                        ))
                                        .frame(width: geo.size.width * progress, height: 2)
                                }
                            }
                            .frame(height: 2)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                            ForEach(ctx.items) { item in
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                                        .fill(accent.opacity(0.80))
                                        .frame(width: 3, height: 14)
                                    Text(item.title)
                                        .font(.system(.footnote, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.85))
                                        .lineLimit(1)
                                    Spacer()
                                    Text(item.subtitle)
                                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                                        .foregroundStyle(accent)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                                Divider().overlay(.white.opacity(0.07)).padding(.horizontal, 16)
                            }

                            HStack {
                                Spacer()
                                Text(ctx.updatedText)
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.30))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                        .background(.black.opacity(0.52))
                    } else {
                        HStack {
                            Text(ctx.progressLabel)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.40))
                            Spacer()
                            Text(ctx.updatedText)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.35))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                }
            }
            .frame(width: family.size.width, height: family.size.height)
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }
}
