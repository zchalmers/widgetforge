import SwiftUI

/// Iridescent holographic foil: two opposing conic gradients create an angular
/// cross-interference sheen over a near-black base, with fine diagonal hatching
/// for the foil-sticker texture and a gradient stroke border that reads as a
/// specular edge catch.
struct HolographicConcept: WidgetConcept {
    static let id = "holographic-iridescent"
    static let title = "Holographic Foil"
    static let blurb = "Angular conic gradient sheen, dark base, foil-sticker iridescence."
    static let preferredScheme: ColorScheme = .dark

    // Spectrum loop: violet → cyan → mint → gold → magenta → violet (closed)
    private static let spectrum: [Color] = [
        Color(red: 0.55, green: 0.15, blue: 1.00),  // 0 violet
        Color(red: 0.00, green: 0.85, blue: 1.00),  // 1 cyan
        Color(red: 0.00, green: 1.00, blue: 0.72),  // 2 mint
        Color(red: 1.00, green: 0.85, blue: 0.15),  // 3 gold
        Color(red: 1.00, green: 0.25, blue: 0.75),  // 4 magenta
        Color(red: 0.55, green: 0.15, blue: 1.00),  // 5 violet again (closes loop)
    ]

    func body(context ctx: ConceptContext, family: ConceptFamily) -> AnyView {
        AnyView(shell(ctx: ctx, family: family))
    }

    // MARK: - Shell (backgrounds + clip + stroke)

    @ViewBuilder
    private func shell(ctx: ConceptContext, family: ConceptFamily) -> some View {
        ZStack {
            // 1. Deep dark base with blue-violet tint
            Color(red: 0.04, green: 0.03, blue: 0.09)

            // 2. Primary conic gradient — main iridescent sweep from bottom-left
            AngularGradient(
                colors: Self.spectrum,
                center: UnitPoint(x: 0.12, y: 0.88),
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
            .opacity(0.52)

            // 3. Counter-rotating conic from top-right — cross-interference shimmer
            AngularGradient(
                colors: Self.spectrum.reversed(),
                center: UnitPoint(x: 0.88, y: 0.12),
                startAngle: .degrees(30),
                endAngle: .degrees(390)
            )
            .opacity(0.22)
            .blendMode(.screen)

            // 4. Fine diagonal hatching — foil-grid texture
            Canvas { gCtx, size in
                let step: CGFloat = 10
                var x: CGFloat = -size.height
                while x < size.width + size.height {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                    gCtx.stroke(path, with: .color(.white.opacity(0.055)), lineWidth: 0.5)
                    x += step
                }
            }

            // 5. Top-left specular catch
            LinearGradient(
                colors: [.white.opacity(0.18), .clear],
                startPoint: .topLeading,
                endPoint: UnitPoint(x: 0.55, y: 0.55)
            )

            // 6. Content
            if family == .large {
                largeLayout(ctx: ctx)
            } else {
                mediumLayout(ctx: ctx)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous))
        .overlay(
            // Iridescent border — bright at top-left, dims mid, brightens at bottom-right
            RoundedRectangle(cornerRadius: family.cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.70),
                            .white.opacity(0.10),
                            .white.opacity(0.08),
                            .white.opacity(0.50),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }

    // MARK: - Medium layout (360 × 170)

    @ViewBuilder
    private func mediumLayout(ctx: ConceptContext) -> some View {
        HStack(spacing: 0) {
            // Left: metric hero
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(holo(0))
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(0.9)
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(ctx.metricValue)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: holo(0).opacity(0.85), radius: 12, x: 0, y: 0)
                    Text(ctx.metricUnit)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                        .offset(y: -2)
                }
                .padding(.bottom, 5)
                HStack(spacing: 4) {
                    Image(systemName: ctx.trend.symbol)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(holo(1))
                    Text(ctx.metricCaption)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.white.opacity(0.60))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxHeight: .infinity, alignment: .leading)

            // Gradient hairline divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.30), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1)
                .padding(.vertical, 18)

            // Right: count + status
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(ctx.countValue)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: holo(2).opacity(0.80), radius: 8, x: 0, y: 0)
                }
                Text(ctx.countCaption)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.white.opacity(0.60))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                // Status badge with glow dot
                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor(ctx.statusLevel))
                        .frame(width: 6, height: 6)
                        .shadow(color: statusColor(ctx.statusLevel).opacity(0.9), radius: 4)
                    Text(ctx.statusText)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(.white.opacity(0.12), lineWidth: 0.5)
                        )
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    // MARK: - Large layout (360 × 376)

    @ViewBuilder
    private func largeLayout(ctx: ConceptContext) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(holo(0))
                    Text(ctx.appName.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(0.9)
                        .foregroundStyle(.white.opacity(0.70))
                }
                Spacer()
                Text(ctx.updatedText)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.white.opacity(0.42))
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 10)

            // Metric hero
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(ctx.metricValue)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: holo(0).opacity(0.9), radius: 14, x: 0, y: 0)
                VStack(alignment: .leading, spacing: 1) {
                    Text(ctx.metricUnit)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.80))
                    Text(ctx.metricCaption)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.white.opacity(0.50))
                }
                .offset(y: -4)
                Spacer()
                // Trend badge
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: ctx.trend.symbol)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(holo(1))
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                    )
            }
            .padding(.horizontal, 18)

            // Progress row
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(ctx.progressLabel)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Text("\(Int(ctx.progress * 100))%")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(holo(2))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(.white.opacity(0.10))
                            .frame(height: 7)
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [holo(0), holo(2), holo(1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geo.size.width * ctx.progress), height: 7)
                            .shadow(color: holo(1).opacity(0.7), radius: 5, x: 0, y: 0)
                    }
                }
                .frame(height: 7)
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)

            // Divider
            Rectangle()
                .fill(.white.opacity(0.10))
                .frame(height: 1)
                .padding(.horizontal, 18)
                .padding(.top, 14)

            // List section header
            HStack {
                Text(ctx.listTitle.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.42))
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor(ctx.statusLevel))
                        .frame(width: 6, height: 6)
                        .shadow(color: statusColor(ctx.statusLevel), radius: 4)
                    Text(ctx.countCaption)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(holo(3))
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 4)

            // Deal list
            VStack(spacing: 0) {
                ForEach(Array(ctx.items.prefix(4).enumerated()), id: \.offset) { idx, item in
                    HStack(spacing: 10) {
                        // Iridescent left accent bar
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(holo(idx))
                            .frame(width: 3, height: 32)
                            .shadow(color: holo(idx).opacity(0.7), radius: 4, x: 0, y: 0)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.title)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.90))
                                .lineLimit(1)
                            Text(item.subtitle)
                                .font(.system(size: 10, design: .rounded))
                                .foregroundStyle(.white.opacity(0.50))
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(holo(idx).opacity(0.70))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    if idx < 3 {
                        Rectangle()
                            .fill(.white.opacity(0.07))
                            .frame(height: 1)
                            .padding(.leading, 18 + 13)
                    }
                }
            }

            Spacer(minLength: 8)
        }
    }

    // MARK: - Helpers

    /// Cycles through the 5 distinct hues (indices 0–4; index 5 is the loop-close duplicate).
    private func holo(_ index: Int) -> Color {
        Self.spectrum[index % 5]
    }

    private func statusColor(_ level: ConceptContext.StatusLevel) -> Color {
        switch level {
        case .ok:       Color(red: 0.00, green: 1.00, blue: 0.65)
        case .warning:  Color(red: 1.00, green: 0.80, blue: 0.10)
        case .critical: Color(red: 1.00, green: 0.28, blue: 0.38)
        }
    }
}
