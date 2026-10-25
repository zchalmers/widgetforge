import SwiftUI

/// Warm paper minimalism: cream stock background, muted ink-blue type hierarchy,
/// a single terracotta accent dot, and generous breathing room throughout.
struct PaperMinimalConcept: WidgetConcept {
    static let id              = "paper-minimal"
    static let title           = "Paper Minimal"
    static let blurb           = "Cream paper, muted ink-blue type, one terracotta dot — all whitespace."
    static let preferredScheme: ColorScheme = .light

    private let paper  = Color(red: 0.965, green: 0.948, blue: 0.910)
    private let ink    = Color(red: 0.148, green: 0.192, blue: 0.318)
    private let accent = Color(red: 0.688, green: 0.352, blue: 0.258)   // terracotta

    // MARK: – Protocol

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            Group {
                if family == .large {
                    largeFace(ctx)
                } else {
                    mediumFace(ctx)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        )
    }

    // MARK: – Medium  360 × 170

    @ViewBuilder
    private func mediumFace(_ ctx: ConceptContext) -> some View {
        ZStack {
            paper
            VStack(alignment: .leading, spacing: 0) {

                // Eyebrow — app name (spaced caps) + single accent dot
                HStack(alignment: .center, spacing: 0) {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 9, weight: .medium, design: .default))
                        .tracking(1.6)
                        .foregroundStyle(ink.opacity(0.42))
                    Spacer()
                    Circle()
                        .fill(accent)
                        .frame(width: 6, height: 6)
                }

                Spacer(minLength: 0)

                // Metric hero — light serif numerals
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(ctx.metricValue)
                        .font(.system(size: 50, weight: .light, design: .serif))
                        .foregroundStyle(ink)
                    Text(ctx.metricUnit)
                        .font(.system(size: 17, weight: .light, design: .serif))
                        .foregroundStyle(ink.opacity(0.42))
                        .offset(y: -2)
                }

                Text(ctx.metricCaption)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(ink.opacity(0.50))
                    .padding(.top, 4)

                Spacer(minLength: 0)

                // Footer row — timestamp + count badge (plain text, no chip)
                HStack(alignment: .center) {
                    Text(ctx.updatedText)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(ink.opacity(0.30))
                    Spacer()
                    HStack(spacing: 3) {
                        Text("\(ctx.countValue)")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(ink)
                        Text(ctx.countCaption)
                            .font(.system(size: 9, weight: .regular))
                            .foregroundStyle(ink.opacity(0.42))
                    }
                    .lineLimit(1)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
        }
    }

    // MARK: – Large  360 × 376

    @ViewBuilder
    private func largeFace(_ ctx: ConceptContext) -> some View {
        ZStack {
            paper
            VStack(alignment: .leading, spacing: 0) {

                // Eyebrow
                HStack(alignment: .center, spacing: 0) {
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 9, weight: .medium, design: .default))
                        .tracking(1.6)
                        .foregroundStyle(ink.opacity(0.42))
                    Spacer()
                    Circle()
                        .fill(accent)
                        .frame(width: 7, height: 7)
                }
                .padding(.bottom, 18)

                // Metric hero with trend glyph in accent
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(ctx.metricValue)
                        .font(.system(size: 62, weight: .light, design: .serif))
                        .foregroundStyle(ink)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(ctx.metricUnit)
                            .font(.system(size: 19, weight: .light, design: .serif))
                            .foregroundStyle(ink.opacity(0.42))
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(accent)
                    }
                    .offset(y: -8)
                }

                Text(ctx.metricCaption)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(ink.opacity(0.50))
                    .padding(.top, 4)
                    .padding(.bottom, 20)

                // Rule
                ink.opacity(0.10)
                    .frame(height: 1)
                    .padding(.bottom, 16)

                // Progress
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(ctx.progressLabel)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(ink.opacity(0.50))
                        Spacer()
                        Text("\(Int(ctx.progress * 100))%")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(ink)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(ink.opacity(0.10))
                                .frame(height: 2)
                            Capsule()
                                .fill(ink.opacity(0.48))
                                .frame(width: geo.size.width * ctx.progress, height: 2)
                        }
                    }
                    .frame(height: 2)
                }
                .padding(.bottom, 18)

                // Rule
                ink.opacity(0.10)
                    .frame(height: 1)
                    .padding(.bottom, 14)

                // List section label
                Text(ctx.listTitle.uppercased())
                    .font(.system(size: 8, weight: .semibold))
                    .tracking(1.3)
                    .foregroundStyle(ink.opacity(0.33))
                    .padding(.bottom, 10)

                // List rows — title + monospaced subtitle, hairline divider
                ForEach(Array(ctx.items.prefix(3))) { item in
                    HStack(alignment: .firstTextBaseline) {
                        Text(item.title)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(ink)
                            .lineLimit(1)
                        Spacer()
                        Text(item.subtitle)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundStyle(ink.opacity(0.50))
                    }
                    .padding(.vertical, 9)
                    ink.opacity(0.08)
                        .frame(height: 1)
                }

                Spacer(minLength: 0)

                // Footer
                Text(ctx.updatedText)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(ink.opacity(0.30))
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
        }
    }
}
