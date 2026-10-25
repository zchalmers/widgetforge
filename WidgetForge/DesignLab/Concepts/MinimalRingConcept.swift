import SwiftUI

/// Zen progress concept: one dominant ring, thin stroke, percentage hero,
/// everything else whispered at the periphery.
struct MinimalRingConcept: WidgetConcept {
    static let id = "minimal-ring"
    static let title = "Minimal Ring"
    static let blurb = "Single dominant ring, percentage hero, all else whispered — zen and focused."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.09)
                if family == .large {
                    largeBody(ctx: ctx, family: family)
                } else {
                    mediumBody(ctx: ctx, family: family)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }

    // MARK: - Ring primitive

    private func ring(ctx: ConceptContext, diameter: CGFloat, lineWidth: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(ctx.progress))
                .stroke(
                    LinearGradient(
                        colors: [ctx.accent, ctx.accentSecondary],
                        startPoint: .top,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(ctx.progress * 100))%")
                .font(.system(size: diameter * 0.21, weight: .thin, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))
        }
        .frame(width: diameter, height: diameter)
    }

    // MARK: - Medium layout (360 × 170)

    @ViewBuilder
    private func mediumBody(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack(alignment: .topLeading) {
            // Ring + progress label, vertically centered
            VStack(spacing: 5) {
                ring(ctx: ctx, diameter: 118, lineWidth: 5)
                Text(ctx.progressLabel)
                    .font(.system(size: 10, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.25))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // App name — top-left ghost label
            Text(ctx.appName.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(.white.opacity(0.16))
                .padding(.leading, 18)
                .padding(.top, 14)

            // Updated text — bottom-right
            Text(ctx.updatedText)
                .font(.system(size: 8.5, weight: .light, design: .rounded))
                .foregroundStyle(.white.opacity(0.16))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 16)
                .padding(.bottom, 12)
        }
    }

    // MARK: - Large layout (360 × 376)

    @ViewBuilder
    private func largeBody(ctx: ConceptContext, family: ConceptFamily) -> some View {
        VStack(spacing: 0) {
            // ── Hero zone ──────────────────────────────────────────────
            ZStack {
                // Ring + metric caption, centered in the hero zone
                VStack(spacing: 7) {
                    ring(ctx: ctx, diameter: 162, lineWidth: 6)
                    Text(ctx.metricCaption)
                        .font(.system(size: 11, weight: .light, design: .rounded))
                        .foregroundStyle(.white.opacity(0.28))
                }

                // Header row pinned to the top of the hero zone
                VStack(spacing: 0) {
                    HStack {
                        Text(ctx.appName.uppercased())
                            .font(.system(size: 8, weight: .semibold, design: .rounded))
                            .tracking(1.8)
                            .foregroundStyle(.white.opacity(0.16))
                        Spacer()
                        Text(ctx.updatedText)
                            .font(.system(size: 8.5, weight: .light, design: .rounded))
                            .foregroundStyle(.white.opacity(0.16))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 226)

            // ── Hairline divider ──────────────────────────────────────
            Rectangle()
                .fill(.white.opacity(0.06))
                .frame(height: 0.5)
                .padding(.horizontal, 24)

            // ── Whispered list ────────────────────────────────────────
            VStack(alignment: .leading, spacing: 0) {
                Text(ctx.listTitle.uppercased())
                    .font(.system(size: 8, weight: .semibold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.16))
                    .padding(.bottom, 10)

                let prefixItems = Array(ctx.items.prefix(4))
                ForEach(Array(prefixItems.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(ctx.accent.opacity(0.40))
                            .frame(width: 3, height: 3)
                        Text(item.title)
                            .font(.system(size: 12.5, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.50))
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(item.subtitle)
                            .font(.system(size: 11, weight: .light, design: .rounded))
                            .foregroundStyle(.white.opacity(0.26))
                            .lineLimit(1)
                    }
                    .padding(.vertical, 8)
                    if index < prefixItems.count - 1 {
                        Rectangle()
                            .fill(.white.opacity(0.05))
                            .frame(height: 0.5)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            Spacer(minLength: 0)
        }
    }
}
