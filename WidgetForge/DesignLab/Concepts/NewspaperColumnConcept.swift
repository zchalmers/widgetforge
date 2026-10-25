import SwiftUI

/// Newspaper front page: cream newsprint background, condensed black-weight
/// headline, thick+thin double rule, column rule dividers, dense all-caps
/// section headers, dateline masthead. Near-monochrome ink-on-paper palette
/// with a single status colour accent.
struct NewspaperColumnConcept: WidgetConcept {
    static let id             = "newspaper-column"
    static let title          = "Newspaper Front Page"
    static let blurb          = "Condensed bold headline, column rules, dense editorial type, newsprint dateline."
    static let preferredScheme: ColorScheme = .light

    // Ink-on-newsprint palette
    private let ink   = Color(red: 0.10, green: 0.09, blue: 0.07)
    private let paper = Color(red: 0.96, green: 0.93, blue: 0.86)

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(rootView(ctx: ctx, family: family))
    }

    // MARK: - Root

    @ViewBuilder
    private func rootView(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            paper
            VStack(spacing: 0) {
                masthead(appName: ctx.appName)
                doubleRule()
                if family == .large {
                    largePage(ctx: ctx)
                } else {
                    mediumPage(ctx: ctx)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
    }

    // MARK: - Masthead

    @ViewBuilder
    private func masthead(appName: String) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(appName.uppercased())
                .font(.system(size: 14, weight: .black, design: .default))
                .tracking(2.5)
                .foregroundStyle(ink)
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text("MON., JUL. 14, 2026")
                    .font(.system(size: 7.5, weight: .medium, design: .default))
                    .foregroundStyle(ink.opacity(0.55))
                Text("LATE CITY EDITION")
                    .font(.system(size: 7, weight: .bold, design: .default))
                    .tracking(0.8)
                    .foregroundStyle(ink.opacity(0.38))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
    }

    // MARK: - Rules

    @ViewBuilder
    private func doubleRule() -> some View {
        VStack(spacing: 2) {
            Rectangle().fill(ink).frame(height: 2.5)
            Rectangle().fill(ink).frame(height: 0.75)
        }
    }

    @ViewBuilder
    private func hairlineRule() -> some View {
        Rectangle().fill(ink.opacity(0.25)).frame(height: 0.75)
    }

    @ViewBuilder
    private func columnRule() -> some View {
        Rectangle()
            .fill(ink.opacity(0.22))
            .frame(width: 0.75)
    }

    @ViewBuilder
    private func sectionDivider(_ label: String) -> some View {
        HStack(spacing: 8) {
            Rectangle().fill(ink.opacity(0.30)).frame(height: 0.75)
            Text(label)
                .font(.system(size: 7.5, weight: .bold, design: .default))
                .tracking(1.5)
                .foregroundStyle(ink.opacity(0.42))
                .fixedSize()
            Rectangle().fill(ink.opacity(0.30)).frame(height: 0.75)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    // MARK: - Medium page  (360 × 170)

    @ViewBuilder
    private func mediumPage(ctx: ConceptContext) -> some View {
        HStack(alignment: .top, spacing: 0) {

            // Column 1 — hero metric
            VStack(alignment: .leading, spacing: 2) {
                colHead("PIPELINE")
                Spacer(minLength: 2)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(ctx.metricValue)
                        .font(.system(size: 40, weight: .black, design: .default))
                        .foregroundStyle(ink)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                    Text(ctx.metricUnit)
                        .font(.system(size: 15, weight: .bold, design: .default))
                        .foregroundStyle(ink.opacity(0.60))
                }
                Text(ctx.metricCaption)
                    .font(.system(size: 9, weight: .regular, design: .default))
                    .foregroundStyle(ink.opacity(0.62))
                    .lineLimit(1)
                Spacer(minLength: 0)
                HStack(spacing: 3) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 9, weight: .bold))
                    Text(trendLabel(ctx.trend))
                        .font(.system(size: 9, weight: .medium, design: .default))
                }
                .foregroundStyle(ink.opacity(0.68))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            columnRule()

            // Column 2 — deals needing action
            VStack(alignment: .leading, spacing: 2) {
                colHead("ACTIVITY")
                Spacer(minLength: 2)
                Text("\(ctx.countValue)")
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundStyle(ink)
                Text(ctx.countCaption)
                    .font(.system(size: 8.5, weight: .regular, design: .default))
                    .foregroundStyle(ink.opacity(0.62))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                statusTag(ctx.statusLevel)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            columnRule()

            // Column 3 — progress
            VStack(alignment: .leading, spacing: 2) {
                colHead("PROGRESS")
                Spacer(minLength: 2)
                Text(pct(ctx.progress))
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundStyle(ink)
                inkyBar(ctx.progress)
                    .padding(.top, 2)
                Text(ctx.progressLabel)
                    .font(.system(size: 8.5, weight: .regular, design: .default))
                    .foregroundStyle(ink.opacity(0.62))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Text(ctx.updatedText)
                    .font(.system(size: 7.5, weight: .regular, design: .default))
                    .italic()
                    .foregroundStyle(ink.opacity(0.38))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Large page  (360 × 376)

    @ViewBuilder
    private func largePage(ctx: ConceptContext) -> some View {
        VStack(spacing: 0) {

            // ── Hero headline ──────────────────────────────────────────────
            VStack(spacing: 3) {
                Text(ctx.metricCaption.uppercased())
                    .font(.system(size: 8.5, weight: .bold, design: .default))
                    .tracking(2.0)
                    .foregroundStyle(ink.opacity(0.48))
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(ctx.metricValue)
                        .font(.system(size: 56, weight: .black, design: .default))
                        .foregroundStyle(ink)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    Text(ctx.metricUnit)
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .foregroundStyle(ink.opacity(0.58))
                        .alignmentGuide(.firstTextBaseline) { d in d[.bottom] - 8 }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)

            sectionDivider("MARKET OVERVIEW")

            // ── 3-column body ──────────────────────────────────────────────
            HStack(alignment: .top, spacing: 0) {

                // Column 1 — deal list
                VStack(alignment: .leading, spacing: 0) {
                    colHead(ctx.listTitle.uppercased())
                        .padding(.bottom, 5)
                    ForEach(ctx.items) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.system(size: 10, weight: .semibold, design: .default))
                                .foregroundStyle(ink)
                                .lineLimit(1)
                            Text(item.subtitle)
                                .font(.system(size: 8.5, weight: .regular, design: .default))
                                .foregroundStyle(ink.opacity(0.55))
                                .lineLimit(1)
                        }
                        .padding(.vertical, 5)
                        Rectangle()
                            .fill(ink.opacity(0.14))
                            .frame(height: 0.5)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                columnRule()

                // Column 2 — status + trend
                VStack(alignment: .leading, spacing: 8) {
                    colHead("STATUS")
                    statusTag(ctx.statusLevel)
                    Text(ctx.statusText)
                        .font(.system(size: 9, weight: .regular, design: .default))
                        .foregroundStyle(ink.opacity(0.62))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    colHead("TREND")
                    HStack(spacing: 5) {
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(ink)
                        Text(trendLabel(ctx.trend))
                            .font(.system(size: 10, weight: .semibold, design: .default))
                            .foregroundStyle(ink.opacity(0.72))
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                columnRule()

                // Column 3 — completion + open deals
                VStack(alignment: .leading, spacing: 8) {
                    colHead("COMPLETION")
                    Text(pct(ctx.progress))
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundStyle(ink)
                    inkyBar(ctx.progress)
                    Text(ctx.progressLabel)
                        .font(.system(size: 9, weight: .regular, design: .default))
                        .foregroundStyle(ink.opacity(0.62))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    colHead("OPEN DEALS")
                    Text("\(ctx.countValue)")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundStyle(ink)
                    Text(ctx.countCaption)
                        .font(.system(size: 9, weight: .regular, design: .default))
                        .foregroundStyle(ink.opacity(0.62))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            hairlineRule()

            // ── Footer ─────────────────────────────────────────────────────
            HStack {
                Text(ctx.updatedText)
                    .font(.system(size: 7.5, weight: .regular, design: .default))
                    .italic()
                    .foregroundStyle(ink.opacity(0.38))
                Spacer()
                Text("\(ctx.metricValue) \(ctx.metricUnit)  •  \(ctx.metricCaption.uppercased())")
                    .font(.system(size: 7.5, weight: .medium, design: .default))
                    .tracking(0.3)
                    .foregroundStyle(ink.opacity(0.38))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Shared sub-views

    @ViewBuilder
    private func colHead(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 7.5, weight: .bold, design: .default))
            .tracking(1.5)
            .foregroundStyle(ink.opacity(0.44))
    }

    @ViewBuilder
    private func statusTag(_ level: ConceptContext.StatusLevel) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(levelColor(level))
                .frame(width: 5, height: 5)
            Text(level.label.uppercased())
                .font(.system(size: 8, weight: .bold, design: .default))
                .tracking(0.8)
                .foregroundStyle(levelColor(level))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(levelColor(level).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .strokeBorder(levelColor(level).opacity(0.32), lineWidth: 0.75)
        )
    }

    @ViewBuilder
    private func inkyBar(_ progress: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(ink.opacity(0.12))
                    .frame(height: 5)
                Rectangle()
                    .fill(ink.opacity(0.68))
                    .frame(width: max(0, geo.size.width * progress), height: 5)
            }
        }
        .frame(height: 5)
    }

    // MARK: - Helpers

    private func pct(_ v: Double) -> String { "\(Int(v * 100))%" }

    private func trendLabel(_ t: ConceptContext.Trend) -> String {
        switch t {
        case .up:   return "Trending Up"
        case .down: return "Trending Down"
        case .flat: return "Stable"
        }
    }

    private func levelColor(_ level: ConceptContext.StatusLevel) -> Color {
        switch level {
        case .ok:       return Color(red: 0.12, green: 0.50, blue: 0.25)
        case .warning:  return Color(red: 0.74, green: 0.38, blue: 0.04)
        case .critical: return Color(red: 0.68, green: 0.10, blue: 0.10)
        }
    }
}
