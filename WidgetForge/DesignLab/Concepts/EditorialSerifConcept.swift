import SwiftUI

/// Magazine editorial: warm cream stock, oversized light-weight serif numerals,
/// hairline column rules, small-caps tracking captions. Restrained, print-inspired.
struct EditorialSerifConcept: WidgetConcept {
    static let id              = "editorial-serif"
    static let title           = "Editorial Serif"
    static let blurb           = "Warm cream stock, oversized serif numerals, hairline rules, small-caps captions — magazine-print aesthetic."
    static let preferredScheme: ColorScheme = .light

    // MARK: Palette — warm magazine paper + dark ink
    private static let paper = Color(red: 0.965, green: 0.950, blue: 0.910)
    private static let ink   = Color(red: 0.115, green: 0.090, blue: 0.065)
    private static let rule  = Color(red: 0.695, green: 0.645, blue: 0.575)
    private static let dim   = Color(red: 0.400, green: 0.355, blue: 0.295)

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            Group {
                if family == .medium {
                    mediumBody(ctx: ctx, family: family)
                } else {
                    largeBody(ctx: ctx, family: family)
                }
            }
        )
    }

    // MARK: Medium (360 × 170) — hero metric + secondary count, separated by column rule
    @ViewBuilder
    private func mediumBody(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            Self.paper
            VStack(alignment: .leading, spacing: 0) {
                // Masthead
                HStack {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 8.5, weight: .medium, design: .serif))
                        .tracking(3.0)
                        .foregroundStyle(Self.dim)
                    Spacer()
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 9, weight: .regular, design: .serif))
                        .foregroundStyle(Self.ink.opacity(0.40))
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 8)

                // Editorial top rule — slightly heavier for authority
                Rectangle()
                    .fill(Self.ink.opacity(0.75))
                    .frame(height: 1.0)
                    .padding(.horizontal, 20)

                // Hero number + secondary count, bottom-aligned
                HStack(alignment: .bottom, spacing: 0) {
                    // Primary metric
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text(ctx.metricValue)
                                .font(.system(size: 54, weight: .light, design: .serif))
                                .foregroundStyle(Self.ink)
                                .minimumScaleFactor(0.75)
                                .lineLimit(1)
                            Text(ctx.metricUnit)
                                .font(.system(size: 17, weight: .light, design: .serif))
                                .foregroundStyle(Self.dim)
                                .padding(.bottom, 7)
                        }
                        Text(ctx.metricCaption.uppercased())
                            .font(.system(size: 7.5, weight: .medium, design: .serif))
                            .tracking(2.0)
                            .foregroundStyle(Self.dim)
                    }

                    Spacer(minLength: 16)

                    // Thin vertical column rule
                    Rectangle()
                        .fill(Self.rule)
                        .frame(width: 0.5, height: 46)
                        .padding(.bottom, 16)

                    // Secondary: count
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(ctx.countValue)")
                            .font(.system(size: 30, weight: .light, design: .serif))
                            .foregroundStyle(Self.ink)
                        Text(ctx.countCaption.uppercased())
                            .font(.system(size: 7, weight: .medium, design: .serif))
                            .tracking(1.0)
                            .foregroundStyle(Self.dim)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.leading, 14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer(minLength: 0)

                // Footer hairline + timestamp
                Rectangle()
                    .fill(Self.rule.opacity(0.65))
                    .frame(height: 0.5)
                    .padding(.horizontal, 20)

                Text(ctx.updatedText.uppercased())
                    .font(.system(size: 7, weight: .regular, design: .serif))
                    .tracking(1.5)
                    .foregroundStyle(Self.dim.opacity(0.60))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 7)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: Large (360 × 376) — hero + two-column stats + editorial list
    @ViewBuilder
    private func largeBody(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            Self.paper
            VStack(alignment: .leading, spacing: 0) {
                // Masthead
                HStack {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 9, weight: .medium, design: .serif))
                        .tracking(3.5)
                        .foregroundStyle(Self.dim)
                    Spacer()
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 10, weight: .regular, design: .serif))
                        .foregroundStyle(Self.ink.opacity(0.38))
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 10)

                // Editorial top rule — heavier weight at the head
                Rectangle()
                    .fill(Self.ink.opacity(0.80))
                    .frame(height: 1.5)
                    .padding(.horizontal, 24)

                // Hero metric
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(ctx.metricValue)
                            .font(.system(size: 70, weight: .light, design: .serif))
                            .foregroundStyle(Self.ink)
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)
                        Text(ctx.metricUnit)
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .foregroundStyle(Self.dim)
                            .padding(.bottom, 8)
                    }
                    Text(ctx.metricCaption.uppercased())
                        .font(.system(size: 9, weight: .medium, design: .serif))
                        .tracking(2.8)
                        .foregroundStyle(Self.dim)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 12)

                // Section divider
                Rectangle()
                    .fill(Self.rule)
                    .frame(height: 0.5)
                    .padding(.horizontal, 24)

                // Two-column: count | progress
                HStack(alignment: .top, spacing: 0) {
                    // Count column
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(ctx.countValue)")
                            .font(.system(size: 34, weight: .light, design: .serif))
                            .foregroundStyle(Self.ink)
                        Text(ctx.countCaption.uppercased())
                            .font(.system(size: 7.5, weight: .medium, design: .serif))
                            .tracking(1.5)
                            .foregroundStyle(Self.dim)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Vertical column rule
                    Rectangle()
                        .fill(Self.rule)
                        .frame(width: 0.5)
                        .padding(.vertical, 4)

                    // Progress column — editorial hairline bar
                    VStack(alignment: .leading, spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Self.rule.opacity(0.40))
                                    .frame(height: 1.5)
                                Rectangle()
                                    .fill(Self.ink)
                                    .frame(width: geo.size.width * CGFloat(ctx.progress),
                                           height: 1.5)
                            }
                        }
                        .frame(height: 1.5)
                        .padding(.top, 8)

                        Text(ctx.progressLabel.uppercased())
                            .font(.system(size: 7.5, weight: .medium, design: .serif))
                            .tracking(1.2)
                            .foregroundStyle(Self.dim)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 12)

                // Section divider
                Rectangle()
                    .fill(Self.rule)
                    .frame(height: 0.5)
                    .padding(.horizontal, 24)

                // List section label
                Text(ctx.listTitle.uppercased())
                    .font(.system(size: 8, weight: .semibold, design: .serif))
                    .tracking(2.5)
                    .foregroundStyle(Self.dim)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 4)

                // Deal rows — three items with hairline separators
                ForEach(Array(ctx.items.prefix(3))) { item in
                    VStack(spacing: 0) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.title)
                                .font(.system(size: 12, weight: .regular, design: .serif))
                                .foregroundStyle(Self.ink)
                                .lineLimit(1)
                            Spacer()
                            Text(item.subtitle)
                                .font(.system(size: 10, weight: .light, design: .serif))
                                .foregroundStyle(Self.dim)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)

                        Rectangle()
                            .fill(Self.rule.opacity(0.50))
                            .frame(height: 0.5)
                            .padding(.horizontal, 24)
                    }
                }

                Spacer(minLength: 0)

                // Footer timestamp
                Text(ctx.updatedText.uppercased())
                    .font(.system(size: 7, weight: .regular, design: .serif))
                    .tracking(1.5)
                    .foregroundStyle(Self.dim.opacity(0.55))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }
}
