import Foundation
import WidgetForgeKit
import AppIntents
#if canImport(FoundationModels)
import FoundationModels
#endif

/// "Summarize Widget" — no parameters. Reads every published manifest and
/// asks the on-device model for a one-paragraph natural-language summary.
/// Falls back to a deterministic template if Foundation Models is unavailable.
public struct SummarizeWidgetIntent: AppIntent {
    public static let title: LocalizedStringResource = "Summarize Widget"
    public static let description = IntentDescription("Summarize what your Widget apps are showing right now.")

    public init() {}

    public static var parameterSummary: some ParameterSummary {
        Summary("Summarize my Widget apps")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let digest = WidgetIntentContext.manifestsDigest()
        let fallback = WidgetIntentContext.fallbackSummary()

#if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                do {
                    let session = LanguageModelSession(
                        model: SystemLanguageModel.default,
                        instructions: Instructions {
                            "You summarize a status digest across several Widget apps."
                            "Return one short sentence, calm and factual. No preamble."
                        }
                    )
                    let prompt = Prompt {
                        "Digest:"
                        digest
                        "Summarize in one sentence."
                    }
                    let response = try await session.respond(to: prompt)
                    return .result(dialog: IntentDialog("\(response.content)"))
                } catch {
                    return .result(dialog: IntentDialog("\(fallback)"))
                }
            case .unavailable:
                return .result(dialog: IntentDialog("\(fallback)"))
            @unknown default:
                return .result(dialog: IntentDialog("\(fallback)"))
            }
        }
#endif
        return .result(dialog: IntentDialog("\(fallback)"))
    }
}
