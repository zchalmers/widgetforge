import SwiftUI

/// Raw Swiss brutalism: stark white background, heavy black monospace type,
/// thick black grid rules dividing zones, one hot accent block per family.
/// No soft radii inside; hard rectangles throughout. Utilitarian blueprint energy.
struct BrutalistMonoConcept: WidgetConcept {
    static let id = "brutalist-mono"
    static let title = "Brutalist Mono"
    static let blurb = "Stark white, heavy black monospaced grid, one hot accent block — Swiss brutalism meets the declassified data panel."
    static let preferredScheme: ColorScheme = .light

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        if family == .medium {
            return AnyView(
                mediumLayout(ctx: ctx, family: family)
                    .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
            )
        } else {
            return AnyView(
                largeLayout(ctx: ctx, family: family)
                    .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
            )
        }
    }

    // MARK: - Medium  360 × 170

    @ViewBuilder
    private func mediumLayout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        VStack(spacing: 0) {

            // ── Header row ─────────────────────────────────────────────────
            HStack(alignment: .center, spacing: 0) {
                Text(ctx.appName.uppercased())
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.black)
                    .tracking(2.5)
                Spacer()
                Image(systemName: ctx.trend.symbol)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Color.black)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            // ── Thick grid rule ────────────────────────────────────────────
            Rectangle().fill(Color.black).frame(height: 3)

            // ── Main zone: metric hero (left) │ hot accent count (right) ───
            HStack(spacing: 0) {

                // Metric hero
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(ctx.metricValue)
                            .font(.system(size: 50, weight: .black, design: .monospaced))
                            .foregroundStyle(Color.black)
                        Text(ctx.metricUnit)
                            .font(.system(size: 19, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.black)
                    }
                    Text(ctx.metricCaption.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.black.opacity(0.42))
                        .tracking(1.5)
                }
                .padding(.leading, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                // Thick vertical rule
                Rectangle().fill(Color.black).frame(width: 3)

                // HOT ACCENT BLOCK — deal count
                ZStack {
                    ctx.accent
                    VStack(spacing: 3) {
                        Text("\(ctx.countValue)")
                            .font(.system(size: 42, weight: .black, design: .monospaced))
                            .foregroundStyle(Color.black)
                        Text(ctx.countCaption.uppercased())
                            .font(.system(size: 7, weight: .black, design: .monospaced))
                            .foregroundStyle(Color.black.opacity(0.62))
                            .tracking(0.6)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 8)
                }
                .frame(width: 110)
            }
            .frame(maxHeight: .infinity)

            // ── Thick grid rule ────────────────────────────────────────────
            Rectangle().fill(Color.black).frame(height: 3)

            // ── Footer row ─────────────────────────────────────────────────
            HStack(alignment: .center) {
                Text(ctx.updatedText.uppercased())
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.black.opacity(0.35))
                    .tracking(1)
                Spacer()
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 7, height: 7)
                    Text(ctx.statusLevel.label.uppercased())
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.black)
                        .tracking(1.5)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .frame(width: family.size.width, height: family.size.height)
    }

    // MARK: - Large  360 × 376

    @ViewBuilder
    private func largeLayout(ctx: ConceptContext, family: ConceptFamily) -> some View {
        VStack(spacing: 0) {

            // ── HOT ACCENT BLOCK — header bar ──────────────────────────────
            HStack(alignment: .center, spacing: 0) {
                Text(ctx.appName.uppercased())
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.black)
                    .tracking(2.5)
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 11, weight: .black))
                    Text(ctx.statusLevel.label.uppercased())
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .tracking(1.5)
                }
                .foregroundStyle(Color.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(ctx.accent)

            // ── Thick grid rule ────────────────────────────────────────────
            Rectangle().fill(Color.black).frame(height: 4)

            // ── Metric hero zone ───────────────────────────────────────────
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(ctx.metricValue)
                    .font(.system(size: 64, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.black)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ctx.metricUnit)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.black)
                    Text(ctx.metricCaption.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.black.opacity(0.42))
                        .tracking(1.5)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // ── Thick grid rule ────────────────────────────────────────────
            Rectangle().fill(Color.black).frame(height: 3)

            // ── List section label ─────────────────────────────────────────
            HStack {
                Text(ctx.listTitle.uppercased())
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.black.opacity(0.42))
                    .tracking(2)
                Spacer()
                Text("\(ctx.items.count) ITEMS")
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.black.opacity(0.42))
                    .tracking(1.5)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 7)

            // ── List items with hairline separators ────────────────────────
            ForEach(Array(ctx.items.enumerated()), id: \.offset) { idx, item in
                if idx > 0 {
                    Rectangle().fill(Color.black.opacity(0.14)).frame(height: 1)
                }
                HStack(spacing: 8) {
                    Text(idx + 1 < 10 ? "0\(idx + 1)" : "\(idx + 1)")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.black.opacity(0.26))
                        .frame(width: 20, alignment: .leading)
                    Text(item.title)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                    Spacer()
                    Text(item.subtitle)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.black.opacity(0.50))
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }

            // ── Thick grid rule ────────────────────────────────────────────
            Rectangle().fill(Color.black).frame(height: 3)

            // ── Progress zone ──────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("PROGRESS")
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.black.opacity(0.42))
                        .tracking(2)
                    Spacer()
                    Text("\(Int(ctx.progress * 100))%")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.black)
                }
                // Raw rectangle progress bar — no Charts
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.black.opacity(0.10))
                        Rectangle().fill(Color.black)
                            .frame(width: max(0, geo.size.width * ctx.progress))
                    }
                }
                .frame(height: 10)
                Text(ctx.progressLabel.uppercased())
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.black.opacity(0.40))
                    .tracking(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)

            // ── Thin rule ──────────────────────────────────────────────────
            Rectangle().fill(Color.black).frame(height: 1)

            // ── Footer row ─────────────────────────────────────────────────
            HStack {
                Text(ctx.updatedText.uppercased())
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.black.opacity(0.35))
                    .tracking(1)
                Spacer()
                HStack(spacing: 4) {
                    Rectangle().fill(Color.black).frame(width: 7, height: 7)
                    Text(ctx.statusText)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.black)
                        .tracking(0.6)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
        }
        .background(Color.white)
        .frame(width: family.size.width, height: family.size.height)
    }
}
