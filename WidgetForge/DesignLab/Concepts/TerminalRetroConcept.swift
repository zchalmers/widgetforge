import SwiftUI

/// CRT hacker terminal: pure-black field, phosphor-green monospace numerals,
/// ASCII box-drawing chrome, blinking-cursor footer block, and a faint
/// scanline overlay drawn with Canvas. Dark by conviction.
struct TerminalRetroConcept: WidgetConcept {
    static let id = "terminal-retro"
    static let title = "Terminal Retro"
    static let blurb = "CRT phosphor-green monospace on pure black with scanlines and ASCII framing."
    static let preferredScheme: ColorScheme = .dark

    // Palette — defined once, referenced everywhere
    private let phosphorGreen = Color(red: 0.10, green: 0.90, blue: 0.10)
    private let termBlack     = Color(red: 0.03, green: 0.03, blue: 0.03)
    private let warnAmber     = Color(red: 0.95, green: 0.80, blue: 0.05)
    private let dangerRed     = Color(red: 0.95, green: 0.22, blue: 0.12)

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack(alignment: .topLeading) {
                termBlack

                if family == .large {
                    largeLayout(ctx: ctx)
                } else {
                    mediumLayout(ctx: ctx)
                }

                // CRT scanline overlay — thin dark stripes every 3pt
                Canvas { gfx, size in
                    let step: CGFloat = 3
                    var y: CGFloat = 0
                    while y < size.height {
                        let stripe = Path { p in
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: size.width, y: y))
                        }
                        gfx.stroke(stripe, with: .color(.black.opacity(0.22)), lineWidth: 1)
                        y += step
                    }
                }
                .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }

    // MARK: - Medium layout (360 × 170) ─────────────────────────────────────

    @ViewBuilder
    private func mediumLayout(ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            crtHeader(appName: ctx.appName, trend: ctx.trend)

            HStack(alignment: .center, spacing: 0) {
                // Left column: hero metric
                VStack(alignment: .leading, spacing: 3) {
                    heroMetric(value: ctx.metricValue, unit: ctx.metricUnit, fontSize: 46)
                    Text(ctx.metricCaption.uppercased())
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundStyle(phosphorGreen.opacity(0.32))
                }
                .padding(.leading, 12)

                Spacer()

                // Right column: deal count badge
                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "%02d", ctx.countValue))
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(phosphorGreen)
                        .shadow(color: phosphorGreen.opacity(0.75), radius: 5)
                    Text(ctx.countCaption.uppercased())
                        .font(.system(size: 7, weight: .regular, design: .monospaced))
                        .foregroundStyle(phosphorGreen.opacity(0.32))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 96)
                }
                .padding(.trailing, 12)
            }
            .padding(.top, 8)

            Spacer(minLength: 0)

            crtFooter(updated: ctx.updatedText)
        }
    }

    // MARK: - Large layout (360 × 376) ───────────────────────────────────────

    @ViewBuilder
    private func largeLayout(ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            crtHeader(appName: ctx.appName, trend: ctx.trend)

            VStack(alignment: .leading, spacing: 6) {
                // Hero metric + caption
                heroMetric(value: ctx.metricValue, unit: ctx.metricUnit, fontSize: 52)
                Text(ctx.metricCaption.uppercased())
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .foregroundStyle(phosphorGreen.opacity(0.32))

                scanDivider()

                // ASCII progress bar
                Text(asciiBar(ctx.progress, width: 24))
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(phosphorGreen)
                    .shadow(color: phosphorGreen.opacity(0.55), radius: 3)
                Text(ctx.progressLabel.uppercased())
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .foregroundStyle(phosphorGreen.opacity(0.45))

                // Status line
                HStack(spacing: 5) {
                    Text(statusPrefix(ctx.statusLevel))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(levelColor(ctx.statusLevel))
                        .shadow(color: levelColor(ctx.statusLevel).opacity(0.7), radius: 4)
                    Text(ctx.statusText.uppercased())
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundStyle(phosphorGreen.opacity(0.5))
                        .lineLimit(1)
                }

                scanDivider()

                // Deal list
                Text("// \(ctx.listTitle.uppercased())")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(phosphorGreen.opacity(0.45))

                ForEach(ctx.items) { item in
                    HStack(spacing: 4) {
                        Text(">")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(phosphorGreen.opacity(0.45))
                        Text(item.title)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundStyle(phosphorGreen)
                            .lineLimit(1)
                        Spacer()
                        Text(item.subtitle)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundStyle(phosphorGreen.opacity(0.55))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            Spacer(minLength: 0)

            crtFooter(updated: ctx.updatedText)
        }
    }

    // MARK: - Chrome pieces ───────────────────────────────────────────────────

    @ViewBuilder
    private func crtHeader(appName: String, trend: ConceptContext.Trend) -> some View {
        HStack(spacing: 0) {
            Text("┌─ \(appName.uppercased()) ─")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundStyle(phosphorGreen.opacity(0.5))
                .lineLimit(1)
            Spacer()
            Image(systemName: trend.symbol)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(phosphorGreen)
                .shadow(color: phosphorGreen.opacity(0.9), radius: 5)
            Text(" ─┐")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundStyle(phosphorGreen.opacity(0.5))
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    @ViewBuilder
    private func crtFooter(updated: String) -> some View {
        HStack(spacing: 0) {
            Text("└─ \(updated.uppercased()) ─")
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundStyle(phosphorGreen.opacity(0.32))
                .lineLimit(1)
            Spacer()
            // Static cursor block (phosphor glow)
            Rectangle()
                .fill(phosphorGreen)
                .frame(width: 8, height: 12)
                .shadow(color: phosphorGreen.opacity(0.95), radius: 5)
            Text(" ─┘")
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundStyle(phosphorGreen.opacity(0.32))
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func heroMetric(value: String, unit: String, fontSize: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(value)
                .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                .foregroundStyle(phosphorGreen)
                .shadow(color: phosphorGreen.opacity(0.85), radius: 8)
            Text(unit)
                .font(.system(size: fontSize * 0.37, weight: .regular, design: .monospaced))
                .foregroundStyle(phosphorGreen.opacity(0.55))
        }
    }

    @ViewBuilder
    private func scanDivider() -> some View {
        Text(String(repeating: "─", count: 50))
            .font(.system(size: 8, weight: .regular, design: .monospaced))
            .foregroundStyle(phosphorGreen.opacity(0.22))
            .lineLimit(1)
    }

    // MARK: - Helpers ─────────────────────────────────────────────────────────

    private func asciiBar(_ value: Double, width: Int) -> String {
        let v = max(0.0, min(1.0, value))
        let filled = Int(v * Double(width))
        let empty  = width - filled
        return "[" + String(repeating: "█", count: filled)
             + String(repeating: "░", count: empty)
             + "] \(Int(v * 100))%"
    }

    private func statusPrefix(_ level: ConceptContext.StatusLevel) -> String {
        switch level {
        case .ok:       return "[ OK ]"
        case .warning:  return "[ !! ]"
        case .critical: return "[ XX ]"
        }
    }

    private func levelColor(_ level: ConceptContext.StatusLevel) -> Color {
        switch level {
        case .ok:       return phosphorGreen
        case .warning:  return warnAmber
        case .critical: return dangerRed
        }
    }
}
