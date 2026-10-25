import SwiftUI

/// Reference concept + pipeline-derisking sample. A restrained Liquid-Glass
/// look: layered translucent material, hairline highlight stroke, concentric
/// rounded corners, SF Rounded numerals, a single tinted accent. Proves the
/// ConceptContext -> body(family:) -> PNG harness end to end before the fan-out.
struct SampleGlassConcept: WidgetConcept {
    static let id = "sample-glass"
    static let title = "Liquid Glass (reference)"
    static let blurb = "Layered translucent material, hairline highlight, tinted accent."
    static let preferredScheme: ColorScheme = .dark

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            ZStack {
                // Base gradient behind the glass so the material has something to refract.
                LinearGradient(colors: [ctx.accent.opacity(0.55), ctx.accentSecondary.opacity(0.35)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                Rectangle().fill(.ultraThinMaterial)

                VStack(alignment: .leading, spacing: family == .large ? 16 : 8) {
                    HStack {
                        Text(ctx.appName)
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        Image(systemName: ctx.trend.symbol)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(ctx.accent)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(ctx.metricValue)
                            .font(.system(size: family == .large ? 64 : 44, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(ctx.metricUnit)
                            .font(.system(.title3, design: .rounded).weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Text(ctx.metricCaption)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))

                    if family == .large {
                        Spacer(minLength: 0)
                        ForEach(ctx.items.prefix(3)) { item in
                            HStack {
                                Text(item.title).font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.85)).lineLimit(1)
                                Spacer()
                                Text(item.subtitle).font(.system(.footnote, design: .rounded).weight(.semibold))
                                    .foregroundStyle(ctx.accent)
                            }
                            .padding(.vertical, 6)
                            .overlay(alignment: .bottom) { Divider().overlay(.white.opacity(0.12)) }
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(family == .large ? 20 : 16)
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
        )
    }
}
