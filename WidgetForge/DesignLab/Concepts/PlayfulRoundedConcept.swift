import SwiftUI

/// Friendly & playful: pastel lilac-to-peach gradient, chunky SF Rounded
/// numerals, coral / sky-blue / mint accent bubbles behind numbers and in
/// cards. Approachable, fun, unmistakably non-corporate.
struct PlayfulRoundedConcept: WidgetConcept {
    static let id               = "playful-rounded"
    static let title            = "Playful Rounded"
    static let blurb            = "Pastel gradient, chunky rounded numerals, cheerful accent bubbles — friendly and approachable."
    static let preferredScheme: ColorScheme = .light

    // MARK: Palette (all light-mode pastel)
    private let bgTop       = Color(red: 0.96, green: 0.92, blue: 1.00)  // soft lilac
    private let bgBot       = Color(red: 1.00, green: 0.95, blue: 0.89)  // warm peach
    private let coral       = Color(red: 1.00, green: 0.76, blue: 0.68)  // coral
    private let sky         = Color(red: 0.72, green: 0.89, blue: 1.00)  // sky blue
    private let mint        = Color(red: 0.70, green: 0.97, blue: 0.84)  // mint
    private let inkDark     = Color(red: 0.15, green: 0.09, blue: 0.25)  // deep plum
    private let inkMid      = Color(red: 0.43, green: 0.35, blue: 0.53)  // mid plum

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(
            Group {
                if family == .medium {
                    mediumView(ctx)
                } else {
                    largeView(ctx)
                }
            }
        )
    }

    // MARK: — Medium  (360 × 170)
    @ViewBuilder
    private func mediumView(_ ctx: ConceptContext) -> some View {
        ZStack {
            // Pastel gradient
            LinearGradient(colors: [bgTop, bgBot],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)

            // Decorative blobs (clipped to widget bounds)
            Circle()
                .fill(coral.opacity(0.40))
                .frame(width: 140, height: 140)
                .offset(x: -120, y: -55)
            Circle()
                .fill(sky.opacity(0.36))
                .frame(width: 100, height: 100)
                .offset(x: 130, y: 68)

            HStack(alignment: .center, spacing: 0) {

                // Left — metric hero
                VStack(alignment: .leading, spacing: 0) {
                    // App name pill
                    Text(ctx.appName)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(inkMid)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(coral.opacity(0.48), in: Capsule())

                    Spacer(minLength: 5)

                    // Big number with coral bubble behind
                    ZStack(alignment: .leading) {
                        Circle()
                            .fill(coral.opacity(0.50))
                            .frame(width: 74, height: 74)
                            .offset(x: -7, y: 7)
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text(ctx.metricValue)
                                .font(.system(size: 46, weight: .heavy, design: .rounded))
                                .foregroundStyle(inkDark)
                            Text(ctx.metricUnit)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(inkMid)
                        }
                    }

                    Spacer(minLength: 4)

                    Text(ctx.metricCaption)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(inkMid)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 18)
                .padding(.vertical, 18)

                // Right — count card + progress
                VStack(alignment: .leading, spacing: 10) {
                    // Count in a sky-blue rounded card
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("\(ctx.countValue)")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundStyle(inkDark)
                            Image(systemName: ctx.trend.symbol)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(inkDark)
                        }
                        Text(ctx.countCaption)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(inkMid)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(sky.opacity(0.42), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    // Progress capsule
                    VStack(alignment: .leading, spacing: 3) {
                        PlayfulProgressBar(progress: ctx.progress,
                                           fill: mint,
                                           track: inkMid.opacity(0.12))
                            .frame(height: 9)
                        Text(ctx.progressLabel)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(inkMid)
                            .lineLimit(1)
                    }
                }
                .frame(width: 138)
                .padding(.trailing, 18)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: — Large  (360 × 376)
    @ViewBuilder
    private func largeView(_ ctx: ConceptContext) -> some View {
        ZStack {
            LinearGradient(colors: [bgTop, bgBot],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)

            // Decorative blobs
            Circle()
                .fill(coral.opacity(0.38))
                .frame(width: 210, height: 210)
                .offset(x: -125, y: -140)
            Circle()
                .fill(sky.opacity(0.32))
                .frame(width: 170, height: 170)
                .offset(x: 130, y: 145)
            Circle()
                .fill(mint.opacity(0.30))
                .frame(width: 110, height: 110)
                .offset(x: 105, y: -165)

            VStack(alignment: .leading, spacing: 10) {

                // Header row
                HStack {
                    Text(ctx.appName)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(inkMid)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(coral.opacity(0.48), in: Capsule())
                    Spacer()
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(inkDark)
                        .padding(7)
                        .background(mint.opacity(0.60), in: Circle())
                }

                // Two-column: metric hero | count + progress
                HStack(alignment: .center, spacing: 12) {

                    // Left — big metric bubble
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(coral.opacity(0.50))
                                .frame(width: 80, height: 80)
                                .offset(x: -7, y: 7)
                            HStack(alignment: .firstTextBaseline, spacing: 3) {
                                Text(ctx.metricValue)
                                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                                    .foregroundStyle(inkDark)
                                Text(ctx.metricUnit)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(inkMid)
                            }
                        }
                        Text(ctx.metricCaption)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(inkDark)
                        Text(ctx.statusText)
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundStyle(inkMid)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Right — count card stacked on progress card
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(ctx.countValue)")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundStyle(inkDark)
                            Text(ctx.countCaption)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(inkMid)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(sky.opacity(0.40), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(ctx.progressLabel)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(inkDark)
                                .lineLimit(1)
                            PlayfulProgressBar(progress: ctx.progress,
                                               fill: mint,
                                               track: inkMid.opacity(0.14))
                                .frame(height: 10)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(mint.opacity(0.28), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .frame(maxWidth: .infinity)
                }

                // List card
                VStack(alignment: .leading, spacing: 0) {
                    Text(ctx.listTitle)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(inkMid)
                        .padding(.bottom, 8)

                    let bubbleColors: [Color] = [coral, sky, mint]
                    ForEach(Array(ctx.items.prefix(3).enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(bubbleColors[index % 3])
                                    .frame(width: 26, height: 26)
                                Text("\(index + 1)")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundStyle(inkDark)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.title)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(inkDark)
                                    .lineLimit(1)
                                Text(item.subtitle)
                                    .font(.system(size: 10, weight: .regular, design: .rounded))
                                    .foregroundStyle(inkMid)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        if index < 2 {
                            Rectangle()
                                .fill(inkMid.opacity(0.10))
                                .frame(height: 1)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.50),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                Spacer(minLength: 0)

                Text(ctx.updatedText)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(inkMid.opacity(0.60))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: — Private helpers

private struct PlayfulProgressBar: View {
    let progress: Double
    let fill: Color
    let track: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(track)
                Capsule()
                    .fill(fill)
                    .frame(width: geo.size.width * min(1.0, max(0.0, progress)))
            }
        }
    }
}
