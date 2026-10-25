import SwiftUI

// MARK: - LiquidGlassProConcept

struct LiquidGlassProConcept: WidgetConcept {
    static let id = "liquid-glass-pro"
    static let title = "Liquid Glass Pro"
    static let blurb = "Specular arc, layered glass, refracted accent fringe — advanced Apple-2026 premium calm."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                // 1. Deep dark base
                Color(red: 0.04, green: 0.05, blue: 0.10)

                // 2. Refraction source — accent gradient bleeding up from beneath the glass
                LinearGradient(
                    colors: [
                        ctx.accent.opacity(0.30),
                        ctx.accentSecondary.opacity(0.18),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // 3. Glass sheet
                Rectangle().fill(.ultraThinMaterial)

                // 4. Soft inner glow diffused from top
                LinearGradient(
                    colors: [Color.white.opacity(0.08), Color.clear],
                    startPoint: .top,
                    endPoint: .center
                )

                // 5. Content
                if family == .medium {
                    lgpMediumContent(ctx: ctx, family: family)
                } else {
                    lgpLargeContent(ctx: ctx, family: family)
                }

                // 6. Specular highlight arc — sits on top like glare on physical glass
                lgpSpecularArc(family: family)
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
            .overlay(
                // Refracted color fringe border
                RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                ctx.accent.opacity(0.72),
                                ctx.accentSecondary.opacity(0.52),
                                Color.white.opacity(0.20),
                                ctx.accentSecondary.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
        )
    }

    // MARK: - Specular arc

    @ViewBuilder
    private func lgpSpecularArc(family: ConceptFamily) -> some View {
        let arcW = family.size.width * 0.60
        let arcH: CGFloat = family == .large ? 90.0 : 64.0
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.46), Color.white.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blur(radius: 3)
            .frame(width: arcW, height: arcH)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .offset(y: -arcH * 0.48)
    }

    // MARK: - Medium layout (360 x 170)

    @ViewBuilder
    private func lgpMediumContent(ctx: ConceptContext, family: ConceptFamily) -> some View {
        HStack(alignment: .center, spacing: 0) {

            // Left — metric hero
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Text(ctx.appName)
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.58))
                    Spacer(minLength: 0)
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ctx.accent)
                }
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(ctx.metricValue)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(ctx.metricUnit)
                        .font(.system(.callout, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.60))
                }
                Text(ctx.metricCaption)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.50))
                    .padding(.top, 2)
            }
            .padding(.leading, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)

            // Hairline divider
            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 1)
                .padding(.vertical, 22)

            // Right — status + progress
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(lgpStatusColor(ctx.statusLevel, ctx: ctx))
                        .frame(width: 6, height: 6)
                    Text(ctx.statusLevel.label)
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.82))
                }
                Text(ctx.statusText)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.white.opacity(0.50))
                    .lineLimit(2)
                    .padding(.top, 3)

                Spacer(minLength: 0)

                LGPProgressBar(progress: ctx.progress, accent: ctx.accent)
                    .frame(height: 4)
                Text(ctx.progressLabel)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(.white.opacity(0.42))
                    .padding(.top, 4)
            }
            .padding(.leading, 14)
            .padding(.trailing, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Large layout (360 x 376)

    @ViewBuilder
    private func lgpLargeContent(ctx: ConceptContext, family: ConceptFamily) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header row
            HStack(alignment: .center) {
                Text(ctx.appName)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.88))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 10, weight: .bold))
                    Text(ctx.updatedText)
                        .font(.system(.caption2, design: .rounded))
                }
                .foregroundStyle(ctx.accent.opacity(0.85))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            // Metric hero card
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [ctx.accent.opacity(0.14), ctx.accentSecondary.opacity(0.09)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.13), lineWidth: 0.5)

                HStack(alignment: .bottom, spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(ctx.metricValue)
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(ctx.metricUnit)
                                .font(.system(.title2, design: .rounded).weight(.medium))
                                .foregroundStyle(.white.opacity(0.62))
                        }
                        Text(ctx.metricCaption)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.52))
                    }
                    Spacer()
                    LGPSparkLine(accent: ctx.accent, accentSecondary: ctx.accentSecondary)
                        .frame(width: 68, height: 38)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .frame(height: 90)
            .padding(.horizontal, 20)

            // Progress module
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .font(.system(.caption, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.52))
                    Spacer()
                    Text(ctx.progressLabel)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.42))
                }
                LGPProgressBar(progress: ctx.progress, accent: ctx.accent)
                    .frame(height: 5)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // List title
            Text(ctx.listTitle)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(.white.opacity(0.52))
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 8)

            // Action items
            let itemArray = Array(ctx.items.prefix(4))
            ForEach(0..<itemArray.count, id: \.self) { index in
                let item = itemArray[index]
                HStack(spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(ctx.accent)
                        .frame(width: 20, height: 20)
                        .background(ctx.accent.opacity(0.14), in: Circle())

                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.title)
                            .font(.system(.footnote, design: .rounded).weight(.medium))
                            .foregroundStyle(.white.opacity(0.90))
                            .lineLimit(1)
                        Text(item.subtitle)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.48))
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.22))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(index % 2 == 0 ? Color.white.opacity(0.035) : Color.clear)
            }

            Spacer(minLength: 0)

            // Footer status strip
            HStack(spacing: 6) {
                Circle()
                    .fill(lgpStatusColor(ctx.statusLevel, ctx: ctx))
                    .frame(width: 5, height: 5)
                Text(ctx.statusText)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.42))
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Status color helper

    private func lgpStatusColor(_ level: ConceptContext.StatusLevel, ctx: ConceptContext) -> Color {
        switch level {
        case .ok:       return ctx.accent
        case .warning:  return Color(red: 1.0, green: 0.76, blue: 0.20)
        case .critical: return Color(red: 1.0, green: 0.36, blue: 0.36)
        }
    }
}

// MARK: - Progress bar (GeometryReader-backed, fills given frame height)

private struct LGPProgressBar: View {
    let progress: Double
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.10))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [accent, accent.opacity(0.55)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geo.size.width * CGFloat(min(max(progress, 0), 1))))
            }
        }
    }
}

// MARK: - Spark line (Canvas — no Charts import)

private struct LGPSparkLine: View {
    let accent: Color
    let accentSecondary: Color
    private let data: [CGFloat] = [0.30, 0.48, 0.38, 0.62, 0.52, 0.70, 0.58, 0.78, 0.65, 0.82]

    var body: some View {
        Canvas { context, size in
            guard data.count > 1 else { return }
            let w = size.width
            let h = size.height
            let step = w / CGFloat(data.count - 1)

            // Line path
            var linePath = Path()
            for (i, val) in data.enumerated() {
                let pt = CGPoint(x: CGFloat(i) * step, y: h - val * h)
                if i == 0 { linePath.move(to: pt) } else { linePath.addLine(to: pt) }
            }

            // Area fill beneath line
            var fillPath = linePath
            let lastX = CGFloat(data.count - 1) * step
            fillPath.addLine(to: CGPoint(x: lastX, y: h))
            fillPath.addLine(to: CGPoint(x: 0, y: h))
            fillPath.closeSubpath()
            context.fill(fillPath, with: .color(accent.opacity(0.18)))

            // Stroke
            context.stroke(linePath, with: .color(accent.opacity(0.82)), lineWidth: 1.5)

            // Terminal dot
            if let lastVal = data.last {
                let dotX = CGFloat(data.count - 1) * step
                let dotY = h - lastVal * h
                let dotRect = CGRect(x: dotX - 3, y: dotY - 3, width: 6, height: 6)
                context.fill(Path(ellipseIn: dotRect), with: .color(accent))
            }
        }
    }
}
