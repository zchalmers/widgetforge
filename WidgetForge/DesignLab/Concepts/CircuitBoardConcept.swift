import SwiftUI

@MainActor
struct CircuitBoardConcept: WidgetConcept {
    static let id              = "circuit-board"
    static let title           = "Circuit Board"
    static let blurb           = "PCB trace art: right-angle gold paths, via pads, and a chip-labeled metric on dark board-green."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                // Board-green gradient base
                LinearGradient(
                    colors: [Color(red: 0.04, green: 0.17, blue: 0.07),
                             Color(red: 0.03, green: 0.11, blue: 0.05)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                // PCB trace canvas
                Canvas { gc, size in
                    let gold   = GraphicsContext.Shading.color(Color(red: 0.82, green: 0.65, blue: 0.15))
                    let faint  = GraphicsContext.Shading.color(Color(red: 0.82, green: 0.65, blue: 0.15).opacity(0.28))
                    let pad    = GraphicsContext.Shading.color(Color(red: 0.90, green: 0.76, blue: 0.28))
                    let hole   = GraphicsContext.Shading.color(Color(red: 0.04, green: 0.14, blue: 0.06))
                    let w = size.width, h = size.height

                    // Dot-matrix background grid
                    for xi in stride(from: CGFloat(18), through: w - 18, by: 18) {
                        for yi in stride(from: CGFloat(18), through: h - 18, by: 18) {
                            var d = Path(); d.addEllipse(in: CGRect(x: xi-1, y: yi-1, width: 2, height: 2))
                            gc.fill(d, with: faint)
                        }
                    }

                    // Nested helpers take explicit params — Swift 6 safe
                    func hline(_ gc: inout GraphicsContext, y: CGFloat, x0: CGFloat, x1: CGFloat,
                               shading: GraphicsContext.Shading, lw: CGFloat = 1.5) {
                        var p = Path(); p.move(to: CGPoint(x: x0, y: y)); p.addLine(to: CGPoint(x: x1, y: y))
                        gc.stroke(p, with: shading, lineWidth: lw)
                    }
                    func vline(_ gc: inout GraphicsContext, x: CGFloat, y0: CGFloat, y1: CGFloat,
                               shading: GraphicsContext.Shading, lw: CGFloat = 1.5) {
                        var p = Path(); p.move(to: CGPoint(x: x, y: y0)); p.addLine(to: CGPoint(x: x, y: y1))
                        gc.stroke(p, with: shading, lineWidth: lw)
                    }
                    func via(_ gc: inout GraphicsContext, at pt: CGPoint, r: CGFloat = 5) {
                        var o = Path(); o.addEllipse(in: CGRect(x: pt.x-r, y: pt.y-r, width: r*2, height: r*2))
                        gc.fill(o, with: pad)
                        var h2 = Path(); let hr = r * 0.42
                        h2.addEllipse(in: CGRect(x: pt.x-hr, y: pt.y-hr, width: hr*2, height: hr*2))
                        gc.fill(h2, with: hole)
                    }

                    // Backbone geometry
                    let x1 = w*0.11, x2 = w*0.37, x3 = w*0.63, x4 = w*0.89
                    let yT = h*0.27, yB = h*0.73

                    hline(&gc, y: yT, x0: x1, x1: x4, shading: gold)
                    hline(&gc, y: yB, x0: x1, x1: x4, shading: gold)
                    vline(&gc, x: x1, y0: yT, y1: yB, shading: gold)
                    vline(&gc, x: x4, y0: yT, y1: yB, shading: gold)
                    vline(&gc, x: x2, y0: yT, y1: yB, shading: gold)
                    vline(&gc, x: x3, y0: yT, y1: yB, shading: gold)

                    for pt in [CGPoint(x:x1,y:yT), CGPoint(x:x1,y:yB),
                                CGPoint(x:x4,y:yT), CGPoint(x:x4,y:yB),
                                CGPoint(x:x2,y:yT), CGPoint(x:x2,y:yB),
                                CGPoint(x:x3,y:yT), CGPoint(x:x3,y:yB)] {
                        via(&gc, at: pt)
                    }

                    // Progress trace along bottom rail
                    let pY = h * 0.89, pFill = x1 + (x4 - x1) * CGFloat(ctx.progress)
                    hline(&gc, y: pY, x0: x1, x1: x4, shading: faint, lw: 2.5)
                    if pFill > x1 { hline(&gc, y: pY, x0: x1, x1: pFill, shading: gold, lw: 2.5) }
                    via(&gc, at: CGPoint(x: pFill, y: pY), r: 4)

                    // Large-only extra trace web in mid/lower region
                    if h > 200 {
                        let yM = h * 0.50
                        hline(&gc, y: yM, x0: x1, x1: x4, shading: gold)
                        vline(&gc, x: w*0.25, y0: yB, y1: h*0.94, shading: gold)
                        vline(&gc, x: w*0.50, y0: yM, y1: yB, shading: gold)
                        vline(&gc, x: w*0.75, y0: yB, y1: h*0.94, shading: gold)
                        for pt in [CGPoint(x:w*0.25,y:yM), CGPoint(x:w*0.50,y:yM), CGPoint(x:w*0.75,y:yM),
                                    CGPoint(x:w*0.25,y:yB), CGPoint(x:w*0.50,y:yB), CGPoint(x:w*0.75,y:yB)] {
                            via(&gc, at: pt)
                        }
                    }
                }

                // Content overlay
                if family == .large {
                    largeOverlay(ctx: ctx)
                } else {
                    mediumOverlay(ctx: ctx)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous)
                    .strokeBorder(Color(red: 0.75, green: 0.58, blue: 0.12).opacity(0.55), lineWidth: 1)
            }
        )
    }

    // MARK: - Medium layout
    private func mediumOverlay(ctx: ConceptContext) -> some View {
        HStack(alignment: .center, spacing: 0) {
            chipBlock(ctx: ctx, compact: true)
                .padding(.leading, 16)
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                HStack(spacing: 4) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(red: 0.82, green: 0.65, blue: 0.15))
                    Text(ctx.statusText)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }
                Text("×\(ctx.countValue)")
                    .font(.system(size: 26, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.82, green: 0.65, blue: 0.15))
                Text(ctx.countCaption)
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.40))
                    .lineLimit(1)
            }
            .padding(.trailing, 16)
        }
    }

    // MARK: - Large layout
    private func largeOverlay(ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            chipBlock(ctx: ctx, compact: false)
                .padding(.horizontal, 16).padding(.top, 16)
            Spacer(minLength: 0)
            // Progress label row
            HStack {
                Text(ctx.progressLabel.uppercased())
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.38))
                Spacer()
                Text(String(format: "%.0f%%", ctx.progress * 100))
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.82, green: 0.65, blue: 0.15))
            }
            .padding(.horizontal, 16)
            Spacer(minLength: 0)
            // IC pin list
            VStack(spacing: 0) {
                ForEach(Array(ctx.items.enumerated()), id: \.offset) { idx, item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 0.82, green: 0.65, blue: 0.15))
                            .frame(width: 5, height: 5)
                        Text(item.title)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.82))
                            .lineLimit(1)
                        Spacer()
                        Text(item.subtitle)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color(red: 0.82, green: 0.65, blue: 0.15))
                            .lineLimit(1)
                    }
                    .padding(.vertical, 6).padding(.horizontal, 16)
                    if idx < ctx.items.count - 1 {
                        Rectangle()
                            .fill(Color(red: 0.82, green: 0.65, blue: 0.15).opacity(0.14))
                            .frame(height: 1).padding(.horizontal, 26)
                    }
                }
            }
            .background(Color.black.opacity(0.28))
            // Footer
            HStack {
                Text(ctx.updatedText.uppercased())
                    .font(.system(size: 7, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.28))
                Spacer()
            }
            .padding(.horizontal, 16).padding(.vertical, 5)
        }
    }

    // MARK: - Chip block
    private func chipBlock(ctx: ConceptContext, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: compact ? 2 : 5) {
            Text("IC-\(ctx.appName.prefix(3).uppercased())")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.38))
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(ctx.metricValue)
                    .font(.system(size: compact ? 42 : 58, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                Text(ctx.metricUnit)
                    .font(.system(size: compact ? 15 : 20, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(red: 0.82, green: 0.65, blue: 0.15))
            }
            Text(ctx.metricCaption)
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.42))
                .lineLimit(1)
        }
    }
}
