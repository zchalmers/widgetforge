import SwiftUI

@MainActor
struct AuroraNoiseFieldConcept: WidgetConcept {
    static let id               = "aurora-noise-field"
    static let title            = "Aurora Noise Field"
    static let blurb            = "Overlapping blurred aurora ribbons over deep space with additive glow, star specks, and an ethereal metric readout."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        let w   = family.size.width
        let h   = family.size.height
        let big = family == .large

        return AnyView(
            ZStack {

                // ── 1. Deep space base ───────────────────────────────────────
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.02, blue: 0.12),
                        Color(red: 0.01, green: 0.00, blue: 0.07)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )

                // ── 2. Star field ────────────────────────────────────────────
                Canvas { gc, size in
                    let count = big ? 160 : 80
                    var s: UInt64 = 0xFACEBEEF_DEADCAFE
                    func rnd() -> Double {
                        s = s &* 6364136223846793005 &+ 1442695040888963407
                        return Double((s >> 33) & 0xFFFFFF) / 16_777_215.0
                    }
                    for _ in 0..<count {
                        let x = rnd() * Double(size.width)
                        let y = rnd() * Double(size.height)
                        let r = rnd() * 1.0 + 0.25
                        let a = rnd() * 0.55 + 0.25
                        gc.fill(
                            Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                            with: .color(Color.white.opacity(a))
                        )
                    }
                }

                // ── 3. Aurora ribbon A — teal ────────────────────────────────
                Rectangle()
                    .fill(LinearGradient(
                        colors: [ctx.accent.opacity(0),
                                 ctx.accent.opacity(0.9),
                                 ctx.accent.opacity(0)],
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: w * 1.5, height: big ? 150 : 75)
                    .rotationEffect(.degrees(-25))
                    .offset(x: -w * 0.05, y: big ? -h * 0.18 : -h * 0.10)
                    .blur(radius: big ? 38 : 22)
                    .blendMode(.screen)

                // ── 4. Aurora ribbon B — violet ──────────────────────────────
                Rectangle()
                    .fill(LinearGradient(
                        colors: [ctx.accentSecondary.opacity(0),
                                 ctx.accentSecondary.opacity(0.78),
                                 ctx.accentSecondary.opacity(0)],
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: w * 1.3, height: big ? 110 : 55)
                    .rotationEffect(.degrees(-14))
                    .offset(x: w * 0.08, y: big ? h * 0.08 : h * 0.12)
                    .blur(radius: big ? 28 : 16)
                    .blendMode(.screen)

                // ── 5. Aurora ribbon C — green (large) ───────────────────────
                if big {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.05, green: 0.90, blue: 0.45).opacity(0),
                                     Color(red: 0.05, green: 0.90, blue: 0.45).opacity(0.45),
                                     Color(red: 0.05, green: 0.90, blue: 0.45).opacity(0)],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: w * 1.4, height: 80)
                        .rotationEffect(.degrees(-38))
                        .offset(x: w * 0.20, y: -h * 0.28)
                        .blur(radius: 30)
                        .blendMode(.screen)
                }

                // ── 6. Hairline shimmer stripes ──────────────────────────────
                ForEach([-0.08, 0.04] as [Double], id: \.self) { frac in
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [.clear, ctx.accent.opacity(0.45), .clear],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: w, height: 1)
                        .blur(radius: 1.5)
                        .blendMode(.screen)
                        .offset(y: h * frac)
                }

                // ── 7. Hero bloom glow ───────────────────────────────────────
                RadialGradient(
                    colors: [ctx.accent.opacity(0.32), .clear],
                    center: .leading,
                    startRadius: 0,
                    endRadius: big ? 185 : 120
                )
                .blendMode(.screen)
                .offset(x: -w * 0.25)

                // ── 8. Content ───────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 0) {

                    // Header row
                    HStack(spacing: 6) {
                        Text(ctx.appName.uppercased())
                            .font(.system(size: 8, design: .monospaced).weight(.semibold))
                            .tracking(2.4)
                            .foregroundStyle(ctx.accent)
                        Spacer()
                        HStack(spacing: 3) {
                            Image(systemName: ctx.trend.symbol)
                                .font(.system(size: 9, design: .default).weight(.bold))
                                .foregroundStyle(ctx.accent)
                            Text(ctx.statusText)
                                .font(.system(size: 8, design: .monospaced).weight(.regular))
                                .foregroundStyle(.white.opacity(0.45))
                        }
                    }
                    .padding(.bottom, big ? 14 : 10)

                    // Hero metric
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(ctx.metricValue)
                            .font(.system(size: big ? 70 : 50, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                            .shadow(color: ctx.accent.opacity(0.9), radius: 18)
                            .shadow(color: ctx.accent.opacity(0.5), radius: 38)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ctx.metricUnit)
                                .font(.system(.title2, design: .rounded).weight(.semibold))
                                .foregroundStyle(ctx.accent)
                            Text(ctx.metricCaption)
                                .font(.system(size: 9, design: .monospaced).weight(.regular))
                                .foregroundStyle(.white.opacity(0.45))
                                .lineLimit(1)
                        }
                    }
                    .padding(.bottom, big ? 12 : 4)

                    // ── Medium-only footer ───────────────────────────────────
                    if !big {
                        Spacer(minLength: 0)
                        HStack(spacing: 8) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(.white.opacity(0.10)).frame(height: 2)
                                    Capsule()
                                        .fill(LinearGradient(
                                            colors: [ctx.accent, ctx.accentSecondary],
                                            startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * ctx.progress, height: 2)
                                }
                            }
                            .frame(height: 2)
                            Text("\(Int(ctx.progress * 100))%")
                                .font(.system(size: 8, design: .monospaced).weight(.bold))
                                .foregroundStyle(ctx.accent.opacity(0.8))
                        }
                        .padding(.bottom, 5)
                        Text(ctx.updatedText)
                            .font(.system(size: 8, design: .monospaced).weight(.regular))
                            .foregroundStyle(.white.opacity(0.25))
                    }

                    // ── Large-only content ───────────────────────────────────
                    if big {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle().stroke(.white.opacity(0.08), lineWidth: 3)
                                    .frame(width: 46, height: 46)
                                Circle()
                                    .trim(from: 0, to: ctx.progress)
                                    .stroke(
                                        AngularGradient(colors: [ctx.accent, ctx.accentSecondary],
                                                        center: .center),
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .frame(width: 46, height: 46)
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: ctx.accent.opacity(0.7), radius: 5)
                                Text("\(Int(ctx.progress * 100))%")
                                    .font(.system(size: 10, design: .rounded).weight(.bold))
                                    .foregroundStyle(.white)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(ctx.progressLabel)
                                    .font(.system(size: 10, design: .monospaced).weight(.medium))
                                    .foregroundStyle(.white.opacity(0.55))
                                HStack(spacing: 4) {
                                    Text("\(ctx.countValue)")
                                        .font(.system(.title3, design: .rounded).weight(.bold))
                                        .foregroundStyle(ctx.accentSecondary)
                                    Text(ctx.countCaption)
                                        .font(.system(size: 9, design: .monospaced).weight(.regular))
                                        .foregroundStyle(.white.opacity(0.45))
                                }
                            }
                            Spacer()
                            Text(ctx.statusLevel.label.uppercased())
                                .font(.system(size: 7, design: .monospaced).weight(.bold))
                                .tracking(1.5)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(ctx.accentSecondary.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(ctx.accentSecondary.opacity(0.4), lineWidth: 0.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                .foregroundStyle(ctx.accentSecondary)
                        }
                        .padding(.bottom, 10)

                        LinearGradient(colors: [ctx.accent.opacity(0.35), .clear],
                                       startPoint: .leading, endPoint: .trailing)
                            .frame(height: 0.5)
                            .padding(.bottom, 8)

                        Text(ctx.listTitle.uppercased())
                            .font(.system(size: 7, design: .monospaced).weight(.semibold))
                            .tracking(2.0)
                            .foregroundStyle(.white.opacity(0.30))
                            .padding(.bottom, 5)

                        ForEach(ctx.items) { item in
                            HStack(spacing: 8) {
                                Circle().fill(ctx.accent.opacity(0.55))
                                    .frame(width: 3, height: 3)
                                Text(item.title)
                                    .font(.system(size: 11, design: .default).weight(.regular))
                                    .foregroundStyle(.white.opacity(0.78))
                                    .lineLimit(1)
                                Spacer()
                                Text(item.subtitle)
                                    .font(.system(size: 11, design: .monospaced).weight(.semibold))
                                    .foregroundStyle(ctx.accent)
                            }
                            .padding(.vertical, 3)
                            .overlay(alignment: .bottom) {
                                Rectangle().fill(.white.opacity(0.05)).frame(height: 0.5)
                            }
                        }

                        Spacer(minLength: 0)
                        Text(ctx.updatedText)
                            .font(.system(size: 8, design: .monospaced).weight(.regular))
                            .foregroundStyle(.white.opacity(0.25))
                    }
                }
                .padding(big ? 20 : 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(width: w, height: h)
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }
}
