import SwiftUI

/// Glassmorphism: colorful blurred blobs (accent + secondary) behind frosted
/// ultraThinMaterial cards with faint white borders. Floating depth.
struct GlassFrostConcept: WidgetConcept {
    static let id = "glass-frost"
    static let title = "Glass Frost"
    static let blurb = "Blurred color blobs behind frosted ultraThinMaterial cards with faint white borders — floating glassmorphism depth."
    static let preferredScheme: ColorScheme = .dark

    init() {}

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                // Deep dark base so the material has contrast to read as glass
                Color(red: 0.05, green: 0.05, blue: 0.11)

                // Blurred color blob layer — bleeds through the frosted cards
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    ZStack {
                        Circle()
                            .fill(ctx.accent.opacity(0.60))
                            .frame(width: w * 0.72)
                            .blur(radius: 48)
                            .offset(x: -w * 0.16, y: -h * 0.14)
                        Circle()
                            .fill(ctx.accentSecondary.opacity(0.52))
                            .frame(width: w * 0.62)
                            .blur(radius: 42)
                            .offset(x: w * 0.28, y: h * 0.32)
                    }
                    .frame(width: w, height: h)
                }

                // Family-specific content
                if family == .medium {
                    mediumBody(ctx: ctx, family: family)
                } else {
                    largeBody(ctx: ctx, family: family)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.22), lineWidth: 1)
            )
        )
    }

    // MARK: - Medium (360 × 170) — metric hero left, count + status right

    @ViewBuilder
    private func mediumBody(ctx: ConceptContext, family: ConceptFamily) -> some View {
        HStack(spacing: 10) {
            // Metric hero card
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(ctx.appName)
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(ctx.accent)
                }
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(ctx.metricValue)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(ctx.metricUnit)
                        .font(.system(.title3, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.58))
                }
                Text(ctx.metricCaption)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.48))
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassCard(cornerRadius: 16)

            // Count + status column
            VStack(spacing: 8) {
                // Count card
                VStack(spacing: 3) {
                    Text("\(ctx.countValue)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(ctx.accentSecondary)
                    Text(ctx.countCaption)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .glassCard(cornerRadius: 14)

                // Status pill
                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor(ctx.statusLevel))
                        .frame(width: 6, height: 6)
                    Text(ctx.statusLevel.label)
                        .font(.system(size: 10, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.20), lineWidth: 1))
            }
            .frame(width: 112)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Large (360 × 376) — header, metric+count, progress, list

    @ViewBuilder
    private func largeBody(ctx: ConceptContext, family: ConceptFamily) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // App name row
            HStack {
                Text(ctx.appName)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.90))
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ctx.accent)
                Text(ctx.updatedText)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.38))
            }

            // Metric + count row (fixed height)
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(ctx.metricValue)
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(ctx.metricUnit)
                            .font(.system(.title2, design: .rounded).weight(.medium))
                            .foregroundStyle(.white.opacity(0.58))
                    }
                    Text(ctx.metricCaption)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.48))
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .glassCard(cornerRadius: 16)

                VStack(spacing: 3) {
                    Text("\(ctx.countValue)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(ctx.accentSecondary)
                    Text(ctx.countCaption)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(14)
                .frame(width: 118)
                .frame(maxHeight: .infinity)
                .glassCard(cornerRadius: 16)
            }
            .frame(height: 88)

            // Progress card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(ctx.progressLabel)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                    Spacer()
                    Text("\(Int(ctx.progress * 100))%")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundStyle(ctx.accent)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.10))
                            .frame(height: 5)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [ctx.accent, ctx.accentSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * ctx.progress, height: 5)
                    }
                }
                .frame(height: 5)
            }
            .padding(14)
            .glassCard(cornerRadius: 16)

            // List card
            VStack(alignment: .leading, spacing: 0) {
                Text(ctx.listTitle)
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.48))
                    .padding(.bottom, 8)

                ForEach(ctx.items.prefix(4)) { item in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(ctx.accent.opacity(0.80))
                            .frame(width: 3, height: 18)
                        Text(item.title)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.white.opacity(0.88))
                            .lineLimit(1)
                        Spacer()
                        Text(item.subtitle)
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(ctx.accentSecondary)
                    }
                    .padding(.vertical, 5)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.white.opacity(0.07))
                            .frame(height: 1)
                    }
                }
            }
            .padding(14)
            .glassCard(cornerRadius: 16)

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private func statusColor(_ level: ConceptContext.StatusLevel) -> Color {
        switch level {
        case .ok:       return Color(red: 0.18, green: 0.86, blue: 0.40)
        case .warning:  return Color(red: 1.00, green: 0.72, blue: 0.00)
        case .critical: return Color(red: 1.00, green: 0.28, blue: 0.28)
        }
    }
}

// MARK: - View extension for the frosted glass card style

private extension View {
    func glassCard(cornerRadius: CGFloat) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            )
    }
}
