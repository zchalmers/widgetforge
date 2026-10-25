import SwiftUI

/// Dark luxury concept: near-black charcoal, hairline gold rules, thin serif
/// numerals, and tight small-caps labels. Reads like a private-bank dashboard.
struct DarkLuxeConcept: WidgetConcept {

    static let id              = "dark-luxe"
    static let title           = "Dark Luxe"
    static let blurb           = "Near-black charcoal, hairline gold rules, thin serif — private-bank restraint."
    static let preferredScheme: ColorScheme = .dark

    // MARK: — Palette

    private static let bgTop   = Color(red: 0.14, green: 0.12, blue: 0.10)
    private static let bgBot   = Color(red: 0.09, green: 0.08, blue: 0.07)
    private static let gold    = Color(red: 0.82, green: 0.68, blue: 0.38)
    private static let ivory   = Color(red: 0.95, green: 0.93, blue: 0.88)

    // MARK: — Protocol entry-point

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        switch family {
        case .medium: return AnyView(mediumView(ctx, family: family))
        case .large:  return AnyView(largeView(ctx, family: family))
        }
    }

    // MARK: — Medium (360 × 170) — metric hero + compact footer

    @ViewBuilder
    private func mediumView(_ ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            bg
            VStack(alignment: .leading, spacing: 0) {
                header(ctx)
                rule(0.65).padding(.top, 8)
                Spacer(minLength: 0)
                metric(ctx, valueFontSize: 46)
                Spacer(minLength: 0)
                rule(0.65).padding(.bottom, 8)
                footer(ctx)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 17)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: — Large (360 × 376) — metric + deal list + progress

    @ViewBuilder
    private func largeView(_ ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            bg
            VStack(alignment: .leading, spacing: 0) {
                header(ctx)
                rule(0.65).padding(.top, 8)

                metric(ctx, valueFontSize: 50)
                    .padding(.top, 13)
                    .padding(.bottom, 14)

                rule(0.65)
                dealList(ctx)
                rule(0.65)

                Spacer(minLength: 0)

                progressSection(ctx)
                    .padding(.top, 12)

                rule(0.28).padding(.vertical, 8)
                footer(ctx)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: — Shared sub-views

    private var bg: some View {
        LinearGradient(
            colors: [Self.bgTop, Self.bgBot],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    @ViewBuilder
    private func header(_ ctx: ConceptContext) -> some View {
        HStack {
            Text(ctx.appName.uppercased())
                .font(.system(size: 9.5, weight: .regular, design: .serif))
                .kerning(2.8)
                .foregroundStyle(Self.ivory.opacity(0.52))
            Spacer()
            Image(systemName: ctx.trend.symbol)
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(Self.gold)
        }
    }

    @ViewBuilder
    private func metric(_ ctx: ConceptContext, valueFontSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(ctx.metricValue)
                    .font(.system(size: valueFontSize, weight: .light, design: .serif))
                    .foregroundStyle(Self.ivory)
                Text(ctx.metricUnit)
                    .font(.system(size: valueFontSize * 0.38, weight: .light, design: .serif))
                    .foregroundStyle(Self.gold)
            }
            Text(ctx.metricCaption.uppercased())
                .font(.system(size: 8.5, weight: .regular, design: .serif))
                .kerning(1.8)
                .foregroundStyle(Self.ivory.opacity(0.52))
        }
    }

    @ViewBuilder
    private func dealList(_ ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(ctx.listTitle.uppercased())
                .font(.system(size: 8, weight: .regular, design: .serif))
                .kerning(2.2)
                .foregroundStyle(Self.gold)
                .padding(.top, 10)
                .padding(.bottom, 4)

            ForEach(ctx.items) { item in
                rule(0.28)
                HStack {
                    Text(item.title)
                        .font(.system(size: 12, weight: .light, design: .serif))
                        .foregroundStyle(Self.ivory)
                        .lineLimit(1)
                    Spacer()
                    Text(item.subtitle)
                        .font(.system(size: 11, weight: .regular, design: .serif))
                        .foregroundStyle(Self.gold)
                }
                .padding(.vertical, 8)
            }
        }
    }

    @ViewBuilder
    private func progressSection(_ ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Self.gold.opacity(0.15))
                        .frame(height: 1.5)
                    Rectangle()
                        .fill(Self.gold)
                        .frame(
                            width: geo.size.width * CGFloat(min(1.0, max(0.0, ctx.progress))),
                            height: 1.5
                        )
                }
            }
            .frame(height: 1.5)

            Text(ctx.progressLabel)
                .font(.system(size: 8.5, weight: .regular, design: .serif))
                .kerning(1.0)
                .foregroundStyle(Self.ivory.opacity(0.52))
        }
    }

    @ViewBuilder
    private func footer(_ ctx: ConceptContext) -> some View {
        HStack {
            Text("\(ctx.countValue) \(ctx.countCaption)")
                .font(.system(size: 9, weight: .regular, design: .serif))
                .kerning(0.8)
                .foregroundStyle(Self.ivory.opacity(0.52))
            Spacer()
            HStack(spacing: 5) {
                Circle()
                    .fill(Self.gold)
                    .frame(width: 4, height: 4)
                Text(ctx.statusLevel.label.uppercased())
                    .font(.system(size: 8.5, weight: .regular, design: .serif))
                    .kerning(1.5)
                    .foregroundStyle(Self.gold)
            }
        }
    }

    private func rule(_ opacity: Double) -> some View {
        Rectangle()
            .fill(Self.gold.opacity(opacity))
            .frame(height: 0.5)
    }
}
