import SwiftUI

/// Three to four frosted-glass planes suspended at staggered depths —
/// graduated scale, offset, rotation, and blur simulate a parallax card
/// stack frozen in space, with accent glows bleeding through every layer.
@MainActor
struct LayeredParallaxGlassConcept: WidgetConcept {
    static let id = "layered-parallax-glass"
    static let title = "Layered Parallax Glass"
    static let blurb = "Multi-plane frosted-glass cards at staggered depths with tinted accent glows bleeding through each layer."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(root(ctx: ctx, family: family))
    }

    // MARK: - Root

    private func root(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            ambientBackground(ctx: ctx, size: family.size)
            if family == .large {
                largeStack(ctx: ctx, family: family)
            } else {
                mediumStack(ctx: ctx, family: family)
            }
        }
        .frame(width: family.size.width, height: family.size.height)
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Background

    private func ambientBackground(ctx: ConceptContext, size: CGSize) -> some View {
        Canvas { gc, sz in
            gc.fill(Path(CGRect(origin: .zero, size: sz)), with: .color(Color(white: 0.04)))

            let r1 = sz.width * 0.68
            var p1 = Path()
            p1.addEllipse(in: CGRect(x: -r1 * 0.22, y: -r1 * 0.22, width: r1, height: r1))
            gc.fill(p1, with: .color(ctx.accent.opacity(0.26)))

            let r2 = sz.width * 0.56
            var p2 = Path()
            p2.addEllipse(in: CGRect(x: sz.width - r2 * 0.72, y: sz.height - r2 * 0.72, width: r2, height: r2))
            gc.fill(p2, with: .color(ctx.accentSecondary.opacity(0.21)))

            let sp: CGFloat = 20, dr: CGFloat = 1.0
            var x = sp
            while x < sz.width {
                var y = sp
                while y < sz.height {
                    var dp = Path()
                    dp.addEllipse(in: CGRect(x: x - dr, y: y - dr, width: dr * 2, height: dr * 2))
                    gc.fill(dp, with: .color(.white.opacity(0.055)))
                    y += sp
                }
                x += sp
            }
        }
        .frame(width: size.width, height: size.height)
    }

    // MARK: - Medium stack (360×170)

    private func mediumStack(ctx: ConceptContext, family: ConceptFamily) -> some View {
        let cw = family.size.width * 0.77
        let ch = family.size.height * 0.75
        let cr: CGFloat = 14

        return ZStack {
            // Depth 3 — back ghost: app name + timestamp
            glassCard(w: cw, h: ch, cr: cr) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(ctx.appName)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                    Text(ctx.updatedText)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.32))
                    Spacer()
                }
                .padding(12)
            }
            .scaleEffect(0.83)
            .offset(x: -15, y: 10)
            .rotationEffect(.degrees(-4))
            .opacity(0.40)
            .blur(radius: 1.8)

            // Depth 2 — mid: progress
            glassCard(w: cw, h: ch, cr: cr) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(ctx.progressLabel)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.55))
                        Spacer()
                        Text("\(Int(ctx.progress * 100))%")
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .foregroundStyle(ctx.accent)
                    }
                    progressTrack(value: ctx.progress, accent: ctx.accent, width: cw - 24)
                    Spacer()
                }
                .padding(12)
            }
            .scaleEffect(0.91)
            .offset(x: -6, y: 5)
            .rotationEffect(.degrees(-1.8))
            .opacity(0.60)
            .blur(radius: 0.5)

            // Depth 1 — front: hero metric
            glassCard(w: cw, h: ch, cr: cr) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(ctx.appName)
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        Image(systemName: ctx.trend.symbol)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(ctx.accent)
                    }
                    Spacer(minLength: 0)
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(ctx.metricValue)
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(ctx.metricUnit)
                            .font(.system(.title3, design: .rounded).weight(.medium))
                            .foregroundStyle(.white.opacity(0.62))
                    }
                    Text(ctx.metricCaption)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.52))
                }
                .padding(14)
            }
            .shadow(color: ctx.accent.opacity(0.22), radius: 18, y: 7)
        }
    }

    // MARK: - Large stack (360×376)

    private func largeStack(ctx: ConceptContext, family: ConceptFamily) -> some View {
        let cw = family.size.width * 0.82
        let ch = family.size.height * 0.56
        let cr: CGFloat = 18

        return ZStack {
            // Depth 4 — deepest ghost: list items
            glassCard(w: cw, h: ch, cr: cr) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(ctx.listTitle)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.42))
                    ForEach(ctx.items.prefix(3)) { item in
                        HStack {
                            Text(item.title)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.38))
                            Spacer()
                            Text(item.subtitle)
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundStyle(ctx.accentSecondary.opacity(0.55))
                        }
                    }
                    Spacer()
                }
                .padding(14)
            }
            .scaleEffect(0.78)
            .offset(x: -22, y: 38)
            .rotationEffect(.degrees(-5))
            .opacity(0.33)
            .blur(radius: 2.5)

            // Depth 3 — progress + status
            glassCard(w: cw, h: ch * 0.72, cr: cr) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Circle().fill(ctx.accent).frame(width: 7, height: 7)
                        Text(ctx.statusText)
                            .font(.system(.caption, design: .rounded).weight(.medium))
                            .foregroundStyle(.white.opacity(0.62))
                        Spacer()
                        Text(ctx.statusLevel.label)
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                            .foregroundStyle(ctx.accent)
                    }
                    progressTrack(value: ctx.progress, accent: ctx.accent, width: cw - 28)
                    Text("\(Int(ctx.progress * 100))% \(ctx.progressLabel)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.42))
                    Spacer()
                }
                .padding(14)
            }
            .scaleEffect(0.88)
            .offset(x: -10, y: 22)
            .rotationEffect(.degrees(-2.5))
            .opacity(0.56)
            .blur(radius: 0.9)

            // Depth 2 — readable item list
            glassCard(w: cw, h: ch, cr: cr) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ctx.listTitle)
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.bottom, 3)
                    ForEach(ctx.items) { item in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(ctx.accentSecondary)
                                .frame(width: 3, height: 12)
                            Text(item.title)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.82))
                                .lineLimit(1)
                            Spacer()
                            Text(item.subtitle)
                                .font(.system(.footnote, design: .rounded).weight(.semibold))
                                .foregroundStyle(ctx.accent)
                        }
                        .padding(.vertical, 3)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(.white.opacity(0.07)).frame(height: 0.5)
                        }
                    }
                    Spacer()
                }
                .padding(14)
            }
            .offset(x: 5, y: 6)
            .rotationEffect(.degrees(1.2))
            .opacity(0.76)

            // Depth 1 — front hero card
            glassCard(w: cw, h: ch * 0.58, cr: cr) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(ctx.appName)
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.92))
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName: ctx.trend.symbol)
                                .font(.caption.weight(.bold))
                            Text("\(ctx.countValue) \(ctx.countCaption)")
                                .font(.system(.caption2, design: .rounded))
                        }
                        .foregroundStyle(ctx.accent)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(ctx.metricValue)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(ctx.metricUnit)
                            .font(.system(.title2, design: .rounded).weight(.medium))
                            .foregroundStyle(.white.opacity(0.60))
                        Spacer()
                    }
                    Text(ctx.metricCaption)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.52))
                }
                .padding(20)
            }
            .offset(x: 14, y: -family.size.height * 0.27)
            .shadow(color: ctx.accent.opacity(0.32), radius: 26, y: 10)
        }
        .frame(width: family.size.width, height: family.size.height)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func glassCard<C: View>(w: CGFloat, h: CGFloat, cr: CGFloat, @ViewBuilder content: () -> C) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: cr, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: cr, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.11), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: cr, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.36), .white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
            VStack(alignment: .leading) { content() }
        }
        .frame(width: w, height: h)
        .shadow(color: .black.opacity(0.44), radius: 14, x: 0, y: 7)
    }

    private func progressTrack(value: Double, accent: Color, width: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            Capsule().fill(.white.opacity(0.10)).frame(width: width, height: 4)
            Capsule()
                .fill(LinearGradient(colors: [accent, accent.opacity(0.48)], startPoint: .leading, endPoint: .trailing))
                .frame(width: max(0, CGFloat(value) * width), height: 4)
        }
        .frame(width: width, height: 4)
    }
}
