import SwiftUI

/// Data-viz hero: enormous heavy metric number, custom bar chart and smooth
/// sparkline drawn with Canvas/Path, trend arrow, and a multi-module large
/// layout. Deep navy background, electric accent, analytical monospaced captions.
struct BoldDataVizConcept: WidgetConcept {
    static let id = "bold-dataviz"
    static let title = "Bold Data Viz"
    static let blurb = "Enormous metric hero, custom bar chart, sparkline, and trend arrow on a deep analytical canvas."
    static let preferredScheme: ColorScheme = .dark

    // Eight historical data points used for both bar chart and sparkline.
    private let chartValues: [Double] = [0.38, 0.52, 0.45, 0.68, 0.55, 0.74, 0.62, 0.88]

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        switch family {
        case .medium:
            return AnyView(mediumLayout(ctx: ctx, family: family))
        case .large:
            return AnyView(largeLayout(ctx: ctx, family: family))
        }
    }

    // MARK: - Medium (360 x 170) — metric hero left, bar chart right

    @ViewBuilder
    private func mediumLayout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            Color(red: 0.055, green: 0.063, blue: 0.092)

            RadialGradient(
                colors: [ctx.accent.opacity(0.22), Color.clear],
                center: UnitPoint(x: 0.0, y: 0.5),
                startRadius: 0,
                endRadius: 190
            )

            HStack(alignment: .center, spacing: 0) {

                // Left: metric hero block
                VStack(alignment: .leading, spacing: 0) {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(ctx.accent.opacity(0.72))
                        .tracking(2.2)

                    Spacer(minLength: 6)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(ctx.metricValue)
                            .font(.system(size: 60, weight: .black))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.45)
                            .lineLimit(1)
                        Text(ctx.metricUnit)
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(.white.opacity(0.42))
                    }

                    HStack(spacing: 5) {
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(trendColor(trend: ctx.trend, accent: ctx.accent))
                        Text(ctx.metricCaption)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.44))
                            .lineLimit(1)
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 0)

                    Text(ctx.updatedText)
                        .font(.system(size: 8, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.22))
                        .tracking(0.4)
                }
                .padding(.leading, 20)
                .padding(.vertical, 16)
                .frame(width: 174)

                // Right: bar chart
                let vals = chartValues
                let accentColor = ctx.accent
                Canvas { gc, size in
                    let count = vals.count
                    let gap: CGFloat = 4
                    let totalGaps = gap * CGFloat(count + 1)
                    let barW = (size.width - totalGaps) / CGFloat(count)

                    for (i, v) in vals.enumerated() {
                        let x = gap + CGFloat(i) * (barW + gap)
                        let barH = (size.height - 10) * CGFloat(v)
                        let y = size.height - 5 - barH
                        let rect = CGRect(x: x, y: y, width: barW, height: barH)
                        let path = Path(roundedRect: rect, cornerRadius: 3, style: .continuous)
                        let isLatest = i == count - 1
                        if isLatest {
                            gc.fill(path, with: .color(accentColor))
                        } else {
                            let alpha = 0.22 + (Double(i) / Double(count - 1)) * 0.55
                            gc.fill(path, with: .color(accentColor.opacity(alpha)))
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.trailing, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Large (360 x 376) — hero + sparkline + progress + list

    @ViewBuilder
    private func largeLayout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            Color(red: 0.055, green: 0.063, blue: 0.092)

            RadialGradient(
                colors: [ctx.accentSecondary.opacity(0.14), Color.clear],
                center: UnitPoint(x: 1.05, y: -0.05),
                startRadius: 0,
                endRadius: 270
            )

            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack(alignment: .center) {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(ctx.accent.opacity(0.75))
                        .tracking(2.2)
                    Spacer()
                    statusBadge(ctx: ctx)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

                // Metric hero row
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(ctx.metricValue)
                        .font(.system(size: 84, weight: .black))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(ctx.metricUnit)
                            .font(.system(size: 25, weight: .bold))
                            .foregroundStyle(.white.opacity(0.42))
                        HStack(spacing: 5) {
                            Image(systemName: ctx.trend.symbol)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(trendColor(trend: ctx.trend, accent: ctx.accent))
                            Text(ctx.metricCaption)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.44))
                                .lineLimit(1)
                        }
                    }
                    .padding(.leading, 10)
                    .padding(.bottom, 8)

                    Spacer(minLength: 8)

                    // Count callout
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(ctx.countValue)")
                            .font(.system(size: 34, weight: .black, design: .monospaced))
                            .foregroundStyle(ctx.accentSecondary)
                        Text(ctx.countCaption)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(0.38))
                            .multilineTextAlignment(.trailing)
                            .lineLimit(2)
                            .frame(maxWidth: 72)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)

                // Sparkline
                let sparkVals = chartValues
                let accentColor = ctx.accent
                Canvas { gc, size in
                    guard sparkVals.count > 1 else { return }
                    let pts: [CGPoint] = sparkVals.enumerated().map { i, v in
                        CGPoint(
                            x: (CGFloat(i) / CGFloat(sparkVals.count - 1)) * size.width,
                            y: size.height - 4 - CGFloat(v) * (size.height - 14)
                        )
                    }
                    // Fill under the curve
                    var fill = Path()
                    fill.move(to: CGPoint(x: pts[0].x, y: size.height))
                    fill.addLine(to: pts[0])
                    for i in 1..<pts.count {
                        let p = pts[i - 1], c = pts[i]
                        let dx = (c.x - p.x) * 0.44
                        fill.addCurve(to: c,
                                      control1: CGPoint(x: p.x + dx, y: p.y),
                                      control2: CGPoint(x: c.x - dx, y: c.y))
                    }
                    fill.addLine(to: CGPoint(x: pts[pts.count - 1].x, y: size.height))
                    fill.closeSubpath()
                    gc.fill(fill, with: .color(accentColor.opacity(0.13)))

                    // Stroke
                    var line = Path()
                    line.move(to: pts[0])
                    for i in 1..<pts.count {
                        let p = pts[i - 1], c = pts[i]
                        let dx = (c.x - p.x) * 0.44
                        line.addCurve(to: c,
                                      control1: CGPoint(x: p.x + dx, y: p.y),
                                      control2: CGPoint(x: c.x - dx, y: c.y))
                    }
                    gc.stroke(line, with: .color(accentColor.opacity(0.88)), lineWidth: 2)

                    // Terminal dot with white core
                    if let last = pts.last {
                        gc.fill(Path(ellipseIn: CGRect(x: last.x - 5, y: last.y - 5, width: 10, height: 10)),
                                with: .color(accentColor))
                        gc.fill(Path(ellipseIn: CGRect(x: last.x - 2.5, y: last.y - 2.5, width: 5, height: 5)),
                                with: .color(.white))
                    }
                }
                .frame(height: 58)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 6)

                // Divider
                Rectangle()
                    .fill(.white.opacity(0.07))
                    .frame(height: 1)
                    .padding(.horizontal, 20)

                // Progress row
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(ctx.progressLabel)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.38))
                        Spacer()
                        Text(String(format: "%.0f%%", ctx.progress * 100))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(ctx.accent)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(.white.opacity(0.07))
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [ctx.accent, ctx.accentSecondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * ctx.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 11)

                // List header
                Text(ctx.listTitle.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.28))
                    .tracking(1.6)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)

                // Item rows
                let itemCount = ctx.items.prefix(4).count
                ForEach(Array(ctx.items.prefix(4).enumerated()), id: \.offset) { idx, item in
                    itemRow(item: item, idx: idx, totalCount: itemCount, accent: ctx.accent)
                }

                Spacer(minLength: 0)

                HStack {
                    Spacer()
                    Text(ctx.updatedText)
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.2))
                        .tracking(0.5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func statusBadge(ctx: ConceptContext) -> some View {
        let color = statusColor(level: ctx.statusLevel, accent: ctx.accent)
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 5, height: 5)
            Text(ctx.statusLevel.label.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .tracking(1)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(color.opacity(0.11))
        .clipShape(Capsule())
    }

    @ViewBuilder
    private func itemRow(
        item: ConceptContext.Item,
        idx: Int,
        totalCount: Int,
        accent: Color
    ) -> some View {
        let fraction = 1.0 - Double(idx) / Double(max(totalCount - 1, 1)) * 0.55
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .fill(accent.opacity(0.25 + fraction * 0.75))
                .frame(width: 3, height: 26)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(1)
                Text(item.subtitle)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.36))
                    .lineLimit(1)
            }
            Spacer()

            // Proportional mini-bar
            let barFraction = fraction
            let barAccent = accent
            Canvas { gc, size in
                let w = size.width * CGFloat(barFraction)
                let rect = CGRect(x: size.width - w, y: (size.height - 4) / 2, width: w, height: 4)
                gc.fill(Path(roundedRect: rect, cornerRadius: 2, style: .continuous),
                        with: .color(barAccent.opacity(0.22 + barFraction * 0.42)))
            }
            .frame(width: 48, height: 16)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 7)
        .background(idx % 2 != 0 ? Color.white.opacity(0.025) : Color.clear)
    }

    // MARK: - Helpers

    private func trendColor(trend: ConceptContext.Trend, accent: Color) -> Color {
        switch trend {
        case .up:   return accent
        case .down: return Color(red: 1.0, green: 0.35, blue: 0.35)
        case .flat: return Color(red: 0.95, green: 0.78, blue: 0.28)
        }
    }

    private func statusColor(level: ConceptContext.StatusLevel, accent: Color) -> Color {
        switch level {
        case .ok:       return accent
        case .warning:  return Color(red: 1.0, green: 0.75, blue: 0.2)
        case .critical: return Color(red: 1.0, green: 0.35, blue: 0.35)
        }
    }
}
