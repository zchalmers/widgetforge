import SwiftUI

/// A single widget-design concept. Each variant is one file implementing this,
/// rendering the SAME `ConceptContext` in its own aesthetic. `body(family:)`
/// must fill the given size exactly (the harness frames it) and own its entire
/// look: background, corner treatment, typography, color, layout.
///
/// Main-actor-isolated in full so every conformer (and its SwiftUI helper
/// methods, which are main-actor-inferred) is uniformly isolated — no
/// cross-isolation errors when a concept factors its body into helpers.
@MainActor
protocol WidgetConcept {
    /// Stable slug used in the screenshot filename, e.g. "liquid-glass".
    static var id: String { get }
    /// Human label shown in the gallery index.
    static var title: String { get }
    /// One-line description of the aesthetic direction.
    static var blurb: String { get }
    /// Preferred appearance for flattering rendering.
    static var preferredScheme: ColorScheme { get }

    init()
    @ViewBuilder func body(context: ConceptContext, family: ConceptFamily) -> AnyView
}

extension WidgetConcept {
    nonisolated static var preferredScheme: ColorScheme { .dark }
}

/// Type-erased concept entry for the registry.
struct AnyConcept: Identifiable {
    let id: String
    let title: String
    let blurb: String
    let scheme: ColorScheme
    let make: @MainActor (ConceptContext, ConceptFamily) -> AnyView

    @MainActor
    init<C: WidgetConcept>(_ type: C.Type) {
        self.id = C.id
        self.title = C.title
        self.blurb = C.blurb
        self.scheme = C.preferredScheme
        // Construct + render inside the main-actor closure so no non-Sendable
        // instance is captured across isolation boundaries.
        self.make = { ctx, fam in C().body(context: ctx, family: fam) }
    }
}

/// Every concept registered for the design lab. Agents append their type here.
@MainActor
enum ConceptRegistry {
    static let all: [AnyConcept] = [
        AnyConcept(AuroraGradientConcept.self),
        AnyConcept(AuroraNoiseFieldConcept.self),
        AnyConcept(BentoGridConcept.self),
        AnyConcept(BokehDepthConcept.self),
        AnyConcept(BoldDataVizConcept.self),
        AnyConcept(BrutalistMonoConcept.self),
        AnyConcept(CircuitBoardConcept.self),
        AnyConcept(ContourTopoConcept.self),
        AnyConcept(DarkLuxeConcept.self),
        AnyConcept(DuotoneBoldConcept.self),
        AnyConcept(EditorialSerifConcept.self),
        AnyConcept(GenerativeFlowFieldConcept.self),
        AnyConcept(GlassFrostConcept.self),
        AnyConcept(GlassRefractionConcept.self),
        AnyConcept(GradientMeshConcept.self),
        AnyConcept(HalftoneGradientConcept.self),
        AnyConcept(HexTessellationConcept.self),
        AnyConcept(HolographicConcept.self),
        AnyConcept(LayeredParallaxGlassConcept.self),
        AnyConcept(LiquidChromeBlobConcept.self),
        AnyConcept(LiquidGlassProConcept.self),
        AnyConcept(MinimalRingConcept.self),
        AnyConcept(MonochromeInkConcept.self),
        AnyConcept(NeonCyberConcept.self),
        AnyConcept(NeonWireGlobeConcept.self),
        AnyConcept(NeumorphicConcept.self),
        AnyConcept(NewspaperColumnConcept.self),
        AnyConcept(PaperMinimalConcept.self),
        AnyConcept(ParticleConstellationConcept.self),
        AnyConcept(PlayfulRoundedConcept.self),
        AnyConcept(RadialSunburstConcept.self),
        AnyConcept(RibbonWave3DConcept.self),
        AnyConcept(SampleGlassConcept.self),
        AnyConcept(SpirographWeaveConcept.self),
        AnyConcept(StratifiedLayersConcept.self),
        AnyConcept(SwissInternationalConcept.self),
        AnyConcept(TerminalRetroConcept.self),
        AnyConcept(TypographicPosterConcept.self),
        AnyConcept(VoronoiShatterConcept.self),
        AnyConcept(WarmSunsetConcept.self),
    ]
}
