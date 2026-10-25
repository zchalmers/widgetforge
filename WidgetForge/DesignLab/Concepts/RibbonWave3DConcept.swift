import SwiftUI

@MainActor
struct RibbonWave3DConcept: WidgetConcept {
    static let id                        = "ribbon-wave-3d"
    static let title                     = "Ribbon Wave 3D"
    static let blurb                     = "Stacked sine-ribbons sweep to progress with depth shading — a fluid data-sculpture."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(content(ctx: ctx, family: family))
    }

    // MARK: - Layout shell

    private func content(ctx: ConceptContext, family: ConceptFamily) -> some View {
        let isLarge = family == .large
        return ZStack(alignment: .topLeading) {
            Color.black
            RadialGradient(
                colors: [ctx.accentSecondary.opacity(0.28), .clear],
                center: .init(x: 0.82, y: 0.58),
                startRadius: 8,
                endRadius: family.size.width * 0.85
            )
            Canvas { gc, size in
                ribbons(gcIn: gc, size: size, ctx: ctx, isLarge: isLarge)
            }
            .frame(width: family.size.width, height: family.size.height)
            metrics(ctx: ctx, isLarge: isLarge)
                .padding(isLarge ? 20 : 14)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.22), ctx.accent.opacity(0.10)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 1
                )
        )
    }

    // MARK: - Typography overlay

    @ViewBuilder
    private func metrics(ctx: ConceptContext, isLarge: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Text(ctx.appName)
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.52))
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(ctx.accent)
                Text(ctx.progressLabel)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(ctx.accent.opacity(0.85))
            }
            Spacer(minLength: 0)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(ctx.metricValue)
                    .font(.system(size: isLarge ? 72 : 50, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: ctx.accent.opacity(0.6), radius: 16)
                    .shadow(color: .black.opacity(0.75), radius: 3, x: 0, y: 2)
                Text(ctx.metricUnit)
                    .font(.system(size: isLarge ? 26 : 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
                    .offset(y: isLarge ? -11 : -7)
            }
            Text(ctx.metricCaption)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.42))
                .padding(.top, 1)
            if isLarge { largeExtras(ctx: ctx) }
        }
    }

    @ViewBuilder
    private func largeExtras(ctx: ConceptContext) -> some View {
        HStack(spacing: 6) {
            Circle().fill(.orange).frame(width: 6, height: 6)
            Text(ctx.statusText)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.orange.opacity(0.88))
            Spacer()
            Text("\(ctx.countValue) \(ctx.countCaption)")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.white.opacity(0.42))
        }
        .padding(.top, 9)
        Rectangle().fill(.white.opacity(0.09)).frame(height: 0.5).padding(.vertical, 7)
        VStack(spacing: 0) {
            ForEach(ctx.items.prefix(4)) { item in
                HStack {
                    Text(item.title)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78)).lineLimit(1)
                    Spacer()
                    Text(item.subtitle)
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(ctx.accent)
                }
                .padding(.vertical, 4)
            }
        }
        Spacer(minLength: 0)
        Text(ctx.updatedText)
            .font(.system(size: 9, design: .rounded))
            .foregroundStyle(.white.opacity(0.25))
    }

    // MARK: - Canvas ribbon sculpture

    private func ribbons(gcIn: GraphicsContext, size: CGSize, ctx: ConceptContext, isLarge: Bool) {
        var gc = gcIn
        let count     = isLarge ? 9 : 6
        let progressX = size.width * ctx.progress

        for i in 0..<count {
            let t: CGFloat = CGFloat(i) / CGFloat(count - 1)
            // Ribbons ascend from back (top-ish) to front (bottom-ish), giving depth layering
            let yFrac  = isLarge ? (0.20 + t * 0.52) : (0.16 + t * 0.70)
            let yCtr   = size.height * yFrac
            let freq   = 1.0 + t * 1.3
            let phase  = t * .pi * 1.1 + CGFloat(i) * 0.42
            let amp: CGFloat   = isLarge ? (11 + t * 15) : (8 + t * 11)
            let thick: CGFloat = isLarge ? (6  + t * 20) : (5  + t * 14)
            let alpha          = 0.18 + t * 0.74   // back ribbons dimmer, front vivid

            // Build ribbon outline
            let steps = 100
            var tops = [CGPoint](); tops.reserveCapacity(steps + 1)
            var bots = [CGPoint](); bots.reserveCapacity(steps + 1)
            for s in 0...steps {
                let x  = size.width * CGFloat(s) / CGFloat(steps)
                let sw = CGFloat(s) / CGFloat(steps)
                let y  = yCtr + sin(sw * .pi * 2.0 * freq + phase) * amp
                tops.append(CGPoint(x: x, y: y - thick * 0.5))
                bots.append(CGPoint(x: x, y: y + thick * 0.5))
            }
            var ribbon = Path()
            ribbon.move(to: tops[0])
            tops.dropFirst().forEach { ribbon.addLine(to: $0) }
            bots.reversed().forEach  { ribbon.addLine(to: $0) }
            ribbon.closeSubpath()

            // Filled section (left of progress): vivid accent→accentSecondary gradient
            var gFill = gc
            gFill.clip(to: Path(CGRect(x: 0, y: 0, width: max(progressX, 0), height: size.height)))
            gFill.fill(ribbon, with: .linearGradient(
                Gradient(stops: [
                    .init(color: ctx.accent.opacity(alpha),               location: 0.0),
                    .init(color: ctx.accentSecondary.opacity(alpha * 0.78), location: 1.0)
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: size.height * 0.35)
            ))

            // Unfilled section (right of progress): ghosted white
            var gDim = gc
            let dimRect = CGRect(x: progressX, y: 0, width: max(size.width - progressX, 0), height: size.height)
            gDim.clip(to: Path(dimRect))
            gDim.fill(ribbon, with: .color(.white.opacity(alpha * 0.065)))

            // Highlight the top-edge of the frontmost ribbon only
            if i == count - 1 {
                var topEdge = Path()
                topEdge.move(to: tops[0])
                tops.dropFirst().forEach { topEdge.addLine(to: $0) }
                gc.stroke(topEdge, with: .color(.white.opacity(0.32)), lineWidth: 1.0)
            }
        }
    }
}
