import SwiftUI
import Foundation

/// Bento-box dashboard: modular tiles each holding one datum, each tile
/// a distinct subtle tint, 6 pt gutters, deep-dark fill — the gaps between
/// tiles reveal the near-black background to form the grid lines.
struct BentoGridConcept: WidgetConcept {
    static let id = "bento-grid"
    static let title = "Bento Grid"
    static let blurb = "Per-tile tinted modules on a near-black base, tight gutters, dense dashboard feel."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                // Near-black base — visible in the 6 pt gutter gaps as implicit grid lines
                Color(red: 0.07, green: 0.07, blue: 0.09)

                Group {
                    if family == .medium {
                        BentoMediumLayout(ctx: ctx)
                    } else {
                        BentoLargeLayout(ctx: ctx)
                    }
                }
                .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }
}

// MARK: - Tile container

private struct BentoTile<Content: View>: View {
    let tint: Color
    let content: Content

    init(tint: Color, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint)
            content
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Medium layout  (360 × 170)
// Two-zone split: dominant metric tile on the left, count + status stacked right.

private struct BentoMediumLayout: View {
    let ctx: ConceptContext

    var body: some View {
        HStack(spacing: 6) {

            // ── Metric tile ────────────────────────────────────────────────
            BentoTile(tint: Color(red: 0.05, green: 0.18, blue: 0.18)) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Text(ctx.appName)
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.48))
                        Spacer(minLength: 0)
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(ctx.accent)
                    }
                    Spacer(minLength: 0)
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(ctx.metricValue)
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(ctx.metricUnit)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(ctx.accent)
                    }
                    Text(ctx.metricCaption)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.42))
                        .padding(.top, 2)
                }
                .padding(12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Right column ───────────────────────────────────────────────
            VStack(spacing: 6) {

                // Count tile
                BentoTile(tint: Color(red: 0.13, green: 0.08, blue: 0.24)) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(ctx.countCaption)
                            .font(.system(.caption2, design: .rounded).weight(.medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 4)
                        Text("\(ctx.countValue)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(ctx.accentSecondary)
                    }
                    .padding(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Status tile
                BentoTile(tint: statusTint) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(statusDotColor)
                                .frame(width: 6, height: 6)
                            Text(ctx.statusLevel.label)
                                .font(.system(.caption2, design: .rounded).weight(.semibold))
                                .foregroundStyle(.white.opacity(0.78))
                        }
                        Text(ctx.statusText)
                            .font(.system(size: 9, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.48))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 112)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var statusTint: Color {
        switch ctx.statusLevel {
        case .ok:       Color(red: 0.05, green: 0.18, blue: 0.09)
        case .warning:  Color(red: 0.20, green: 0.13, blue: 0.03)
        case .critical: Color(red: 0.22, green: 0.05, blue: 0.05)
        }
    }

    private var statusDotColor: Color {
        switch ctx.statusLevel {
        case .ok:       Color(red: 0.20, green: 0.80, blue: 0.45)
        case .warning:  Color(red: 0.95, green: 0.65, blue: 0.10)
        case .critical: Color(red: 0.95, green: 0.30, blue: 0.30)
        }
    }
}

// MARK: - Large layout  (360 × 376)
// Three rows: (metric | count) / (status | progress) / full-width list.

private struct BentoLargeLayout: View {
    let ctx: ConceptContext

    var body: some View {
        VStack(spacing: 6) {

            // ── Row 1: metric + count ──────────────────────────────────────
            HStack(spacing: 6) {

                // Metric
                BentoTile(tint: Color(red: 0.05, green: 0.18, blue: 0.18)) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            Text(ctx.appName)
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundStyle(.white.opacity(0.48))
                            Spacer(minLength: 0)
                            Image(systemName: ctx.trend.symbol)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(ctx.accent)
                        }
                        Spacer(minLength: 0)
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text(ctx.metricValue)
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(ctx.metricUnit)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(ctx.accent)
                        }
                        Text(ctx.metricCaption)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.42))
                            .padding(.top, 2)
                    }
                    .padding(14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Count
                BentoTile(tint: Color(red: 0.13, green: 0.08, blue: 0.24)) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(ctx.countCaption)
                            .font(.system(.caption, design: .rounded).weight(.medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(3)
                        Spacer(minLength: 0)
                        Text("\(ctx.countValue)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(ctx.accentSecondary)
                    }
                    .padding(14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)

            // ── Row 2: status + progress ───────────────────────────────────
            HStack(spacing: 6) {

                // Status
                BentoTile(tint: statusTint) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(statusDotColor)
                                .frame(width: 8, height: 8)
                            Text(ctx.statusLevel.label)
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundStyle(.white.opacity(0.82))
                        }
                        Spacer(minLength: 0)
                        Text(ctx.statusText)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.white.opacity(0.62))
                            .lineLimit(3)
                    }
                    .padding(14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Progress
                BentoTile(tint: Color(red: 0.07, green: 0.11, blue: 0.22)) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Progress")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.48))
                        Spacer(minLength: 0)
                        Text(String(format: "%.0f%%", ctx.progress * 100))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.bottom, 8)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(.white.opacity(0.11))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(LinearGradient(
                                        colors: [ctx.accent, ctx.accentSecondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: geo.size.width * max(0, min(1, ctx.progress)), height: 8)
                            }
                        }
                        .frame(height: 8)
                        Text(ctx.progressLabel)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.38))
                            .padding(.top, 5)
                    }
                    .padding(14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)

            // ── Row 3: list ────────────────────────────────────────────────
            BentoTile(tint: Color(red: 0.09, green: 0.09, blue: 0.12)) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(ctx.listTitle)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.48))
                        .padding(.bottom, 8)

                    let cappedItems = Array(ctx.items.prefix(4))
                    ForEach(Array(cappedItems.enumerated()), id: \.offset) { idx, item in
                        HStack(spacing: 0) {
                            // Accent dot
                            Circle()
                                .fill(ctx.accent.opacity(0.55))
                                .frame(width: 5, height: 5)
                                .padding(.trailing, 8)
                            Text(item.title)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text(item.subtitle)
                                .font(.system(.footnote, design: .rounded).weight(.semibold))
                                .foregroundStyle(ctx.accent)
                        }
                        .padding(.vertical, 5)
                        if idx < cappedItems.count - 1 {
                            Rectangle()
                                .fill(.white.opacity(0.07))
                                .frame(height: 1)
                        }
                    }

                    Spacer(minLength: 0)
                    HStack {
                        Spacer()
                        Text(ctx.updatedText)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.22))
                    }
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var statusTint: Color {
        switch ctx.statusLevel {
        case .ok:       Color(red: 0.05, green: 0.18, blue: 0.09)
        case .warning:  Color(red: 0.20, green: 0.13, blue: 0.03)
        case .critical: Color(red: 0.22, green: 0.05, blue: 0.05)
        }
    }

    private var statusDotColor: Color {
        switch ctx.statusLevel {
        case .ok:       Color(red: 0.20, green: 0.80, blue: 0.45)
        case .warning:  Color(red: 0.95, green: 0.65, blue: 0.10)
        case .critical: Color(red: 0.95, green: 0.30, blue: 0.30)
        }
    }
}
