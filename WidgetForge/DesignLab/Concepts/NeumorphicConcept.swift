import SwiftUI

/// Soft neumorphism: single monochrome surface, extruded shapes via dual
/// light/dark drop shadows, zero hard borders, muted accent numerals.
struct NeumorphicConcept: WidgetConcept {
    static let id                               = "neumorphic"
    static let title                            = "Soft Neumorphic"
    static let blurb                            = "Monochrome extruded surface, dual light/dark shadows, tactile and borderless."
    static let preferredScheme: ColorScheme     = .light

    // Palette — all derived from the same neutral hue so shadows read clearly.
    private let surface     = Color(red: 0.878, green: 0.898, blue: 0.926)
    private let textPrimary = Color(red: 0.25,  green: 0.28,  blue: 0.36)
    private let textMuted   = Color(red: 0.50,  green: 0.54,  blue: 0.62)
    private let shadowLight = Color.white
    private let shadowDark  = Color(red: 0.60,  green: 0.63,  blue: 0.70)
    private let accentMuted = Color(red: 0.44,  green: 0.58,  blue: 0.80)  // slate-blue, legible on light

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            Group {
                if family == .medium {
                    mediumLayout(ctx: ctx, family: family)
                } else {
                    largeLayout(ctx: ctx, family: family)
                }
            }
        )
    }

    // MARK: - Medium  360 × 170

    @ViewBuilder
    private func mediumLayout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            surface
            HStack(alignment: .top, spacing: 0) {
                // Left: metric hero + progress strip
                VStack(alignment: .leading, spacing: 6) {
                    Text(ctx.appName)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(textMuted)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(ctx.metricValue)
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(textPrimary)
                        Text(ctx.metricUnit)
                            .font(.system(.title3, design: .rounded).weight(.medium))
                            .foregroundStyle(textMuted)
                    }

                    Text(ctx.metricCaption)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(textMuted)

                    Spacer(minLength: 0)

                    progressStrip(progress: ctx.progress, label: ctx.progressLabel)
                }
                .padding(.leading, 20)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Right: count disc + trend pill
                VStack(spacing: 12) {
                    countDisc(value: ctx.countValue, caption: ctx.countCaption)
                    trendPill(symbol: ctx.trend.symbol)
                }
                .padding(.trailing, 18)
                .padding(.vertical, 18)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Large  360 × 376

    @ViewBuilder
    private func largeLayout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            surface
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text(ctx.appName)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(textMuted)
                    Spacer()
                    trendPill(symbol: ctx.trend.symbol)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

                // Metric + count
                raisedCard {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(ctx.metricValue)
                                    .font(.system(size: 52, weight: .bold, design: .rounded))
                                    .foregroundStyle(textPrimary)
                                Text(ctx.metricUnit)
                                    .font(.system(.title2, design: .rounded).weight(.medium))
                                    .foregroundStyle(textMuted)
                            }
                            Text(ctx.metricCaption)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(textMuted)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(ctx.countValue)")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(accentMuted)
                            Text(ctx.countCaption)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(textMuted)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(2)
                                .frame(maxWidth: 90)
                        }
                    }
                }
                .padding(.horizontal, 16)

                // Progress
                raisedCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Progress")
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                            .foregroundStyle(textMuted)
                        progressStrip(progress: ctx.progress, label: ctx.progressLabel)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // List
                raisedCard {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(ctx.listTitle)
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(textMuted)
                            .padding(.bottom, 8)

                        ForEach(Array(ctx.items.prefix(3).enumerated()), id: \.offset) { idx, item in
                            if idx > 0 {
                                Rectangle()
                                    .fill(shadowDark.opacity(0.18))
                                    .frame(height: 1)
                                    .padding(.vertical, 5)
                            }
                            HStack {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(item.title)
                                        .font(.system(.footnote, design: .rounded).weight(.medium))
                                        .foregroundStyle(textPrimary)
                                        .lineLimit(1)
                                    Text(item.subtitle)
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundStyle(textMuted)
                                        .lineLimit(1)
                                }
                                Spacer()
                                // Raised nub — the classic neumorphic detail
                                Circle()
                                    .fill(surface)
                                    .frame(width: 10, height: 10)
                                    .shadow(color: shadowDark.opacity(0.35), radius: 2, x: 1, y: 1)
                                    .shadow(color: shadowLight.opacity(0.90), radius: 2, x: -1, y: -1)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                Spacer(minLength: 0)

                Text(ctx.updatedText)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(textMuted.opacity(0.65))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Reusable components

    /// A floating panel: same surface color, concentric radius, dual drop-shadow.
    @ViewBuilder
    private func raisedCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: shadowLight,              radius: 7, x: -5, y: -5)
            .shadow(color: shadowDark.opacity(0.40), radius: 7, x:  5, y:  5)
    }

    /// Capsule track + filled capsule progress. No GeometryReader needed — stretch fill uses overlay.
    @ViewBuilder
    private func progressStrip(progress: Double, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(shadowDark.opacity(0.18))
                    Capsule(style: .continuous)
                        .fill(accentMuted.opacity(0.85))
                        .frame(width: geo.size.width * CGFloat(max(0.0, min(1.0, progress))))
                }
            }
            .frame(height: 8)

            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(textMuted)
        }
    }

    /// Extruded circle with a numeric value — the centerpiece of the medium widget.
    @ViewBuilder
    private func countDisc(value: Int, caption: String) -> some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(surface)
                    .frame(width: 58, height: 58)
                    .shadow(color: shadowDark.opacity(0.42), radius: 8, x: 5, y: 5)
                    .shadow(color: shadowLight,              radius: 8, x: -5, y: -5)
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(accentMuted)
            }
            Text(caption)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 72)
        }
    }

    /// Capsule pill with an SF Symbol, raised off the surface.
    @ViewBuilder
    private func trendPill(symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(.footnote, weight: .semibold))
            .foregroundStyle(accentMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(surface)
            .clipShape(Capsule(style: .continuous))
            .shadow(color: shadowDark.opacity(0.38), radius: 5, x: 3, y: 3)
            .shadow(color: shadowLight,              radius: 5, x: -3, y: -3)
    }
}
