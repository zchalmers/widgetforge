import SwiftUI

/// Synthwave neon: near-black void, glowing monospaced numerals, magenta-to-cyan
/// horizon line, retro perspective grid baked into the lower third.
struct NeonCyberConcept: WidgetConcept {
    static let id              = "neon-cyber"
    static let title           = "Neon Cyber"
    static let blurb           = "Synthwave synthetics: near-black void, glowing neon numerals, magenta-to-cyan horizon gradient, retro perspective grid."
    static let preferredScheme: ColorScheme = .dark

    // MARK: - Palette

    private let bg       = Color(red: 0.05, green: 0.03, blue: 0.12)
    private let cyan     = Color(red: 0.05, green: 0.95, blue: 1.00)
    private let magenta  = Color(red: 1.00, green: 0.07, blue: 0.60)
    private let violet   = Color(red: 0.72, green: 0.10, blue: 1.00)
    private let dim      = Color.white.opacity(0.50)

    // MARK: - Protocol

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(rootView(ctx: ctx, family: family))
    }

    @ViewBuilder
    private func rootView(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack(alignment: .topLeading) {
            // Void background
            bg

            // Perspective grid anchored to bottom third
            NeonGrid(cyan: cyan, magenta: magenta)
                .frame(height: family == .large ? 150 : 62)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            // Content layer
            if family == .medium {
                mediumLayout(ctx: ctx)
            } else {
                largeLayout(ctx: ctx)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Medium (360 x 170)

    @ViewBuilder
    private func mediumLayout(ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──
            HStack(spacing: 6) {
                Text(ctx.appName.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(cyan)
                    .tracking(2)
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(magenta)
                    .glow(magenta, r1: 5, r2: 12)
            }

            Spacer(minLength: 4)

            // ── Metric hero ──
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(ctx.metricValue)
                    .font(.system(size: 50, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .glow(cyan, r1: 8, r2: 22)
                Text(ctx.metricUnit)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundStyle(cyan)
                    .glow(cyan, r1: 5, r2: 13)
            }

            Text(ctx.metricCaption.uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(dim)
                .tracking(1.5)
                .padding(.top, 2)

            Spacer(minLength: 8)

            horizonLine()

            Spacer(minLength: 8)

            // ── Footer row ──
            HStack(spacing: 4) {
                Text("\(ctx.countValue)")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(magenta)
                    .glow(magenta, r1: 5, r2: 10)
                Text(ctx.countCaption.uppercased())
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(dim)
                    .tracking(1)
                    .lineLimit(1)
                Spacer()
                statusBadge(ctx.statusLevel.label)
            }
        }
        .padding(16)
    }

    // MARK: - Large (360 x 376)

    @ViewBuilder
    private func largeLayout(ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──
            HStack(spacing: 6) {
                Text(ctx.appName.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(cyan)
                    .tracking(2)
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(magenta)
                    .glow(magenta, r1: 5, r2: 12)
                statusBadge(ctx.statusLevel.label)
            }

            Spacer(minLength: 8)

            // ── Metric hero ──
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(ctx.metricValue)
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .glow(cyan, r1: 10, r2: 28)
                Text(ctx.metricUnit)
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
                    .foregroundStyle(cyan)
                    .glow(cyan, r1: 6, r2: 15)
            }

            Text(ctx.metricCaption.uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(dim)
                .tracking(1.5)
                .padding(.top, 2)

            Spacer(minLength: 10)

            horizonLine()

            Spacer(minLength: 10)

            // ── Progress ──
            HStack {
                Text("PROGRESS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(cyan.opacity(0.70))
                    .tracking(1.5)
                Spacer()
                Text(ctx.progressLabel)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(dim)
            }

            Spacer(minLength: 5)

            NeonProgressBar(progress: ctx.progress, leading: magenta, trailing: cyan)
                .frame(height: 6)

            Spacer(minLength: 12)

            // ── List ──
            Text(ctx.listTitle.uppercased())
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(cyan.opacity(0.70))
                .tracking(1.5)

            Spacer(minLength: 6)

            VStack(spacing: 0) {
                ForEach(Array(ctx.items.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(magenta)
                            .frame(width: 4, height: 4)
                            .shadow(color: magenta.opacity(0.9), radius: 4)
                        Text(item.title)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.85))
                            .lineLimit(1)
                        Spacer()
                        Text(item.subtitle)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(cyan)
                            .glow(cyan, r1: 3, r2: 7)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 6)

                    if index < ctx.items.count - 1 {
                        Rectangle()
                            .fill(violet.opacity(0.25))
                            .frame(height: 1)
                    }
                }
            }

            Spacer(minLength: 0)

            // ── Footer ──
            HStack {
                Spacer()
                Text(ctx.updatedText)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(dim.opacity(0.55))
                    .tracking(0.5)
            }
        }
        .padding(18)
    }

    // MARK: - Shared helpers

    @ViewBuilder
    private func horizonLine() -> some View {
        Rectangle()
            .fill(LinearGradient(
                colors: [magenta, violet, cyan],
                startPoint: .leading,
                endPoint: .trailing
            ))
            .frame(height: 2)
            .shadow(color: magenta.opacity(0.75), radius: 6)
            .shadow(color: cyan.opacity(0.55), radius: 10)
    }

    @ViewBuilder
    private func statusBadge(_ label: String) -> some View {
        Text(label.uppercased())
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundStyle(magenta)
            .tracking(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(magenta.opacity(0.70), lineWidth: 1)
            )
    }
}

// MARK: - Neon Glow modifier

private extension View {
    /// Layered shadow to simulate neon outer glow.
    func glow(_ color: Color, r1: CGFloat, r2: CGFloat) -> some View {
        self
            .shadow(color: color.opacity(0.90), radius: r1)
            .shadow(color: color.opacity(0.50), radius: r2)
    }
}

// MARK: - Perspective Grid

private struct NeonGrid: View {
    let cyan: Color
    let magenta: Color

    var body: some View {
        Canvas { ctx, size in
            let vpX = size.width / 2
            let vpY: CGFloat = 0

            // Radial lines: vanishing point -> bottom edge
            let radialCount = 10
            for i in 0...radialCount {
                let t = CGFloat(i) / CGFloat(radialCount)
                var path = Path()
                path.move(to: CGPoint(x: vpX, y: vpY))
                path.addLine(to: CGPoint(x: t * size.width, y: size.height))
                ctx.stroke(path, with: .color(cyan.opacity(0.20)), lineWidth: 0.6)
            }

            // Horizontal lines with perspective spacing (dense near horizon)
            let hLineCount = 7
            for i in 1...hLineCount {
                let t = pow(CGFloat(i) / CGFloat(hLineCount), 1.7)
                let y = size.height * t
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(path, with: .color(magenta.opacity(0.22)), lineWidth: 0.6)
            }
        }
    }
}

// MARK: - Neon Progress Bar

private struct NeonProgressBar: View {
    let progress: Double
    let leading: Color
    let trailing: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.white.opacity(0.08))

                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(LinearGradient(
                        colors: [leading, trailing],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: max(6, geo.size.width * CGFloat(progress)))
                    .shadow(color: trailing.opacity(0.70), radius: 4)
            }
        }
    }
}
