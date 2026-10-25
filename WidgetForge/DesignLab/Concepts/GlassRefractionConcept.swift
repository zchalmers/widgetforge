import SwiftUI

@MainActor
struct GlassRefractionConcept: WidgetConcept {
    static let id = "glass-refraction"
    static let title = "Glass Refraction"
    static let blurb = "Faux-lens refraction: displaced gradient layers, chromatic-aberration edge fringe, specular highlights."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        let sz       = family.size
        let lensR: CGFloat = family == .large ? 106 : 58
        let lensX: CGFloat = family == .large ? sz.width / 2 : sz.width * 0.37
        let lensY: CGFloat = family == .large ? sz.height * 0.41 : sz.height / 2

        // Extract Sendable values for Canvas capture
        let countSeed: UInt64 = UInt64(ctx.countValue) * 1_234_567 + 89_012
        let accent           = ctx.accent
        let accentSecondary  = ctx.accentSecondary
        let progressFrac     = CGFloat(ctx.progress)

        return AnyView(ZStack {

            // ── 1. Background ──────────────────────────────────────────────
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.04, green: 0.04, blue: 0.14),
                             Color(red: 0.07, green: 0.03, blue: 0.19)],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
                RadialGradient(colors: [accent.opacity(0.38), .clear],
                               center: .topLeading,
                               startRadius: 0, endRadius: sz.width * 0.7)
                RadialGradient(colors: [accentSecondary.opacity(0.32), .clear],
                               center: .bottomTrailing,
                               startRadius: 0, endRadius: sz.height)
            }

            // ── 2. Generative star field (seeded from countValue) ──────────
            Canvas { gc, cSz in
                var rng = SeededRNG(seed: countSeed)
                for _ in 0..<90 {
                    let x = rng.next01() * cSz.width
                    let y = rng.next01() * cSz.height
                    let r = rng.next01() * 1.8 + 0.3
                    gc.fill(
                        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                        with: .color(.white.opacity(rng.next01() * 0.4 + 0.1))
                    )
                }
            }
            .blendMode(.screen).opacity(0.55)

            // ── 3. Chromatic aberration fringe around lens ─────────────────
            Canvas { gc, _ in
                let defs: [(CGFloat, CGFloat, Color, CGFloat)] = [
                    (-2.5, -2.0, .red,   2.5),
                    ( 2.5,  2.0, .blue,  2.5),
                    ( 0.0,  0.0, .green, 1.5),
                ]
                for (dx, dy, color, lw) in defs {
                    let r = lensR + 4.5
                    gc.stroke(
                        Path(ellipseIn: CGRect(x: lensX - r + dx, y: lensY - r + dy,
                                               width: r * 2, height: r * 2)),
                        with: .color(color.opacity(0.44)), lineWidth: lw
                    )
                }
                let og = lensR + 10
                gc.stroke(
                    Path(ellipseIn: CGRect(x: lensX - og, y: lensY - og, width: og * 2, height: og * 2)),
                    with: .color(.white.opacity(0.07)), lineWidth: 7
                )
            }

            // ── 4. Lens body: displaced gradient + frosted glass ───────────
            ZStack {
                ZStack {
                    RadialGradient(
                        colors: [accentSecondary.opacity(0.72), accent.opacity(0.50),
                                 Color(red: 0.04, green: 0.04, blue: 0.16)],
                        center: UnitPoint(x: 0.3, y: 0.28),
                        startRadius: 0, endRadius: lensR * 1.5)
                    RadialGradient(
                        colors: [accent.opacity(0.45), .clear],
                        center: UnitPoint(x: 0.68, y: 0.68),
                        startRadius: 0, endRadius: lensR * 0.9)
                    .blendMode(.screen)
                }
                .blur(radius: 1.5)

                Circle().fill(.ultraThinMaterial).opacity(0.6)

                RadialGradient(colors: [.white.opacity(0.14), .clear],
                               center: .center, startRadius: 0, endRadius: lensR)
            }
            .frame(width: lensR * 2, height: lensR * 2)
            .clipShape(Circle())
            .position(x: lensX, y: lensY)

            // ── 5. Lens rim ────────────────────────────────────────────────
            Circle()
                .strokeBorder(LinearGradient(
                    colors: [.white.opacity(0.70), .white.opacity(0.08), .white.opacity(0.03)],
                    startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5)
                .frame(width: lensR * 2, height: lensR * 2)
                .position(x: lensX, y: lensY)

            // ── 6. Specular highlights ─────────────────────────────────────
            Ellipse()
                .fill(LinearGradient(colors: [.white.opacity(0.80), .clear],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: lensR * 0.85, height: lensR * 0.27)
                .blur(radius: 4)
                .position(x: lensX - lensR * 0.07, y: lensY - lensR * 0.62)

            Ellipse()
                .fill(accentSecondary.opacity(0.28))
                .frame(width: lensR * 0.55, height: lensR * 0.16)
                .blur(radius: 5)
                .position(x: lensX + lensR * 0.32, y: lensY + lensR * 0.55)

            // ── 7. Hero metric centred in lens ─────────────────────────────
            VStack(spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(ctx.metricValue)
                        .font(.system(size: family == .large ? 44 : 26,
                                      weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(ctx.metricUnit)
                        .font(.system(family == .large ? .title3 : .footnote,
                                      design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                }
                Text(ctx.metricCaption)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: lensR * 1.55)
            }
            .shadow(color: .black.opacity(0.5), radius: 3)
            .position(x: lensX, y: lensY + (family == .large ? 6 : 3))

            // ── 8. App name / status overlay ──────────────────────────────
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(ctx.appName)
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                    Spacer()
                    Label(ctx.statusLevel.label, systemImage: ctx.trend.symbol)
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .foregroundStyle(accent)
                }
                .padding(.horizontal, 16).padding(.top, 14)
                Spacer()
                if family == .medium {
                    HStack {
                        Spacer(minLength: lensX + lensR + 14)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ctx.countCaption)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                            Text(ctx.statusText)
                                .font(.system(.caption2, design: .rounded).weight(.medium))
                                .foregroundStyle(accent.opacity(0.85))
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 14)
                }
            }
            .frame(width: sz.width, height: sz.height)

            // ── 9. Large: progress bar + items list ───────────────────────
            if family == .large {
                let listTop = lensY + lensR + 16
                let listH   = sz.height - listTop - 12
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Text(ctx.progressLabel)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(.white.opacity(0.10)).frame(height: 3)
                                Capsule()
                                    .fill(LinearGradient(colors: [accent, accentSecondary],
                                                         startPoint: .leading, endPoint: .trailing))
                                    .frame(width: g.size.width * progressFrac, height: 3)
                            }
                        }
                        .frame(height: 3)
                        Text("\(Int(ctx.progress * 100))%")
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .foregroundStyle(accent)
                    }
                    .padding(.horizontal, 20).padding(.bottom, 10)
                    ForEach(ctx.items.prefix(3)) { item in
                        HStack(spacing: 8) {
                            Circle().fill(accent.opacity(0.55)).frame(width: 4, height: 4)
                            Text(item.title)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.82)).lineLimit(1)
                            Spacer()
                            Text(item.subtitle)
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundStyle(accentSecondary.opacity(0.9))
                        }
                        .padding(.horizontal, 20).padding(.vertical, 5)
                    }
                    Spacer(minLength: 0)
                    Text(ctx.updatedText)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.28))
                        .padding(.horizontal, 20)
                }
                .frame(width: sz.width, height: listH)
                .position(x: sz.width / 2, y: listTop + listH / 2)
            }

        } // ZStack
        .frame(width: sz.width, height: sz.height)
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        ))
    }
}

private struct SeededRNG {
    var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13; state ^= state >> 7; state ^= state << 17; return state
    }
    mutating func next01() -> CGFloat {
        CGFloat(next() & 0x000F_FFFF) / CGFloat(0x000F_FFFF)
    }
}
