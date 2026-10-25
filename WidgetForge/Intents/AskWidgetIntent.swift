import Foundation
import SwiftUI
import WidgetForgeKit
import AppIntents
#if canImport(FoundationModels)
import FoundationModels
#endif

/// "Ask Widget <question>" — reads every published manifest, then answers a free
/// -form question across all of them in one turn. Foundation Models does the
/// reasoning when available; a deterministic heuristic answers otherwise.
///
/// Target phrases (see WidgetShortcuts): "What needs my attention", "Ask Widget …".
public struct AskWidgetIntent: AppIntent {
    public static let title: LocalizedStringResource = "Ask Widget"
    public static let description = IntentDescription("Ask a question across all your Widget apps at once.")

    @Parameter(title: "Question", requestValueDialog: IntentDialog("What do you want to know?"))
    public var question: String

    public init() {}
    public init(question: String) { self.question = question }

    public static var parameterSummary: some ParameterSummary {
        Summary("Ask Widget \(\.$question)")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let digest = WidgetIntentContext.manifestsDigest()
        let fallback = Self.heuristicAnswer(question: question, digest: digest)

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                do {
                    let session = LanguageModelSession(
                        model: SystemLanguageModel.default,
                        instructions: Instructions {
                            "You answer questions about a user's Widget apps from a status digest."
                            "Be concise and factual — two sentences max. No preamble, no markdown."
                            "If the digest doesn't contain the answer, say so plainly."
                        }
                    )
                    let prompt = Prompt {
                        "Widget status digest:"
                        digest
                        "Question:"
                        question
                    }
                    let response = try await session.respond(to: prompt)
                    return .result(
                        dialog: IntentDialog("\(response.content)"),
                        view: AnswerSnippetView(question: question, answer: response.content)
                    )
                } catch {
                    return .result(
                        dialog: IntentDialog("\(fallback)"),
                        view: AnswerSnippetView(question: question, answer: fallback)
                    )
                }
            case .unavailable:
                return .result(
                    dialog: IntentDialog("\(fallback)"),
                    view: AnswerSnippetView(question: question, answer: fallback)
                )
            @unknown default:
                return .result(
                    dialog: IntentDialog("\(fallback)"),
                    view: AnswerSnippetView(question: question, answer: fallback)
                )
            }
        }
        #endif
        return .result(
            dialog: IntentDialog("\(fallback)"),
            view: AnswerSnippetView(question: question, answer: fallback)
        )
    }

    /// Deterministic answer when Apple Intelligence is unavailable. Reads off
    /// the digest so the user still gets a real answer, just not synthesized.
    static func heuristicAnswer(question: String, digest: String) -> String {
        if digest.hasPrefix("No Widget apps") { return digest }
        // The digest is already a compact per-app status line list; the honest
        // non-AI answer is to read it back with a light framing.
        return "Here's what your Widget apps show right now — " +
            digest.replacingOccurrences(of: "\n", with: "; ") + "."
    }
}

/// Compact snippet rendering the Q + A for the Assistant surface.
struct AnswerSnippetView: View {
    let question: String
    let answer: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(answer)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
    }
}
