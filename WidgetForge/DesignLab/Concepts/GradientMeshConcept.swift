import SwiftUI

/// Vibrant mesh gradient background (layered radial blobs of accent + secondary
/// hues across a deep indigo base), crisp white type floating on top.
/// Bold, saturated, modern.
struct GradientMeshConcept: WidgetConcept {
    static let id = "gradient-mesh"
    static let title = "Gradient Mesh"
    static let blurb = "Vibrant mesh gradient of accent + secondary across a deep base, crisp white type, bold and saturated."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                meshBackground(ctx: ctx)

                if family == .medium {
                    mediumContent(ctx: ctx)
                } else {
                    largeContent(ctx: ctx)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }

    // MARK: - Background

    @ViewBuilder
    private func meshBackground(ctx: ConceptContext) -> some View {
        // Deep indigo base so the mesh has a saturated anchor.
        Color(red: 0.05, green: 0.04, blue: 0.18)

        // MeshGradient (iOS 18+): nine control points, accent blobs at corners
        // and secondary blobs pulled toward the interior so colors bleed richly.
        MeshGradient(
            width: 3, height: 3,
            points: [
                .init(0,    0),    .init(0.50, 0),    .init(1,    0),
                .init(0,    0.50), .init(0.45, 0.55), .init(1,    0.50),
                .init(0,    1),    .init(0.55, 1),    .init(1,    1)
            ],
            colors: [
                ctx.accentSecondary,                         // top-left  — full violet
                Color(red: 0.07, green: 0.04, blue: 0.24),  // top-center — deep indigo
                ctx.accent.opacity(0.90),                    // top-right  — teal
                Color(red: 0.04, green: 0.06, blue: 0.22),  // mid-left   — navy
                ctx.accentSecondary.opacity(0.55),           // center     — soft violet
                ctx.accent.opacity(0.60),                    // mid-right  — teal fade
                ctx.accent,                                  // bot-left   — full teal
                Color(red: 0.08, green: 0.04, blue: 0.26),  // bot-center — deep purple
                ctx.accentSecondary.opacity(0.92)            // bot-right  — violet
            ]
        )
    }

    // MARK: - Medium (360 × 170)

    @ViewBuilder
    private func mediumContent(ctx: ConceptContext) -> some View {
        HStack(alignment: .top, spacing: 0) {

            // Left — metric hero
            VStack(alignment: .leading, spacing: 0) {
                Text(ctx.appName.uppercased())
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.62))
                    .tracking(1.8)
                    .padding(.bottom, 8)

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(ctx.metricValue)
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(ctx.metricUnit)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.80))
                }

                Text(ctx.metricCaption)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.62))
                    .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, 20)
            .padding(.vertical, 18)

            Spacer(minLength: 14)

            // Right — status pill + action count
            VStack(alignment: .trailing, spacing: 10) {

                // Status pill
                HStack(spacing: 5) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 11, weight: .bold))
                    Text(ctx.statusLevel.label)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(.white.opacity(0.20))
                )

                Spacer(minLength: 0)

                // Count
                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(ctx.countValue)")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(ctx.countCaption)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.trailing, 20)
            .padding(.vertical, 18)
        }
    }

    // MARK: - Large (360 × 376)

    @ViewBuilder
    private func largeContent(ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                Text(ctx.appName.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
                    .tracking(2.0)
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(.white.opacity(0.18)))
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)

            // Metric hero
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(ctx.metricValue)
                    .font(.system(size: 70, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ctx.metricUnit)
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(ctx.metricCaption)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)

            // Progress bar
            VStack(alignment: .leading, spacing: 5) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(.white.opacity(0.14))
                            .frame(height: 7)
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [ctx.accent, ctx.accentSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geo.size.width * ctx.progress), height: 7)
                    }
                }
                .frame(height: 7)

                Text(ctx.progressLabel)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.52))
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            // Hairline separator
            Rectangle()
                .fill(.white.opacity(0.12))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.top, 18)

            // List section label
            Text(ctx.listTitle.uppercased())
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.48))
                .tracking(1.4)
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 8)

            // Items
            ForEach(ctx.items.prefix(3)) { item in
                HStack(spacing: 11) {
                    // Accent pill
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(ctx.accentSecondary)
                        .frame(width: 3, height: 34)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(item.subtitle)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.56))
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.28))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 7)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.white.opacity(0.09))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                }
            }

            Spacer(minLength: 0)

            // Footer
            HStack(spacing: 5) {
                Circle()
                    .fill(statusDotColor(ctx: ctx))
                    .frame(width: 5, height: 5)
                Text(ctx.updatedText)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.42))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Helpers

    private func statusDotColor(ctx: ConceptContext) -> Color {
        switch ctx.statusLevel {
        case .ok:       return ctx.accent
        case .warning:  return Color(red: 1.0, green: 0.76, blue: 0.20)
        case .critical: return Color(red: 1.0, green: 0.35, blue: 0.35)
        }
    }
}
