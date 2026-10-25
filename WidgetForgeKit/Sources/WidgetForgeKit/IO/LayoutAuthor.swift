import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Builds widget layouts from a natural-language description using Apple's
/// Foundation Models, with a deterministic default-layout fallback. Extracted
/// from `AuthorLayoutIntent` so the App Intent and the in-app "Describe it with
/// AI" flow share one implementation. Neither `generate` nor `seedDefault`
/// persists — callers write via `LayoutStore` and reload timelines.
public enum LayoutAuthor {
    public enum AuthorAvailability: Equatable {
        case available    // model ready
        case unavailable  // supported OS/device but model not ready
        case unsupported  // no Foundation Models / OS too old
    }

    public static func availability() -> AuthorAvailability {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available: return .available
            case .unavailable: return .unavailable
            @unknown default: return .unavailable
            }
        }
        #endif
        return .unsupported
    }

    /// The family default layout (not persisted).
    public static func seedDefault(family: LayoutFamily) -> WidgetLayout {
        LayoutStore.defaultLayout(for: family)
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    public static func generate(prompt userPrompt: String, family: LayoutFamily) async -> WidgetLayout? {
        let suggestions = WidgetIntentContext.sliceSuggestions()
        let vocab = suggestions.map { s in
            "app=\(s.entry.displayName) bundleId=\(s.entry.bundleId) sliceId=\(s.sliceId) kind=\(s.kind.rawValue) name=\(s.sliceDisplayName)"
        }.joined(separator: "\n")

        let session = LanguageModelSession(
            model: SystemLanguageModel.default,
            instructions: Instructions {
                "You design a widget layout from a user's description."
                "Use ONLY the app/slice/kind options provided. Match each cell's kind to its slice kind."
                "The grid for this widget is \(family.cols) columns by \(family.rows) rows, zero-indexed."
                "Prefer a header on the top row plus one or two data cells. Do not overlap cells."
                "For header cells, leave bundleId and sliceId empty and put the label in text."
            }
        )

        func makePrompt(feedback: String?) -> Prompt {
            Prompt {
                "Available data:"
                vocab
                "User request:"
                userPrompt
                if let feedback { "Your previous attempt failed validation: \(feedback). Fix it and try again." }
                else { "Design the widget now." }
            }
        }

        var lastError: String?
        for attempt in 0..<2 {
            guard let response = try? await session.respond(
                to: makePrompt(feedback: lastError),
                generating: LayoutBlueprint.self
            ) else { return nil }
            let input = response.content.toMapperInput(family: family)
            do {
                return try LayoutBlueprintMapper.build(input)
            } catch {
                lastError = String(describing: error)
                if attempt == 1 { return nil }
            }
        }
        return nil
    }
    #endif
}

// MARK: - @Generable DTO (moved from AuthorLayoutIntent)

#if canImport(FoundationModels)
@available(iOS 26.0, *)
@Generable
struct LayoutBlueprint {
    @Guide(description: "Short, human-readable name for the widget")
    var name: String

    @Guide(description: "The cells to place on the grid", .count(1...6))
    var cells: [BlueprintCell]

    func toMapperInput(family: LayoutFamily) -> LayoutBlueprintMapper.LayoutBlueprintInput {
        LayoutBlueprintMapper.LayoutBlueprintInput(
            name: name,
            family: family,
            cells: cells.map { $0.toCellInput() }
        )
    }
}

@available(iOS 26.0, *)
@Generable
struct BlueprintCell {
    @Guide(description: "Component kind: one of count, list, metric, status, progress, header")
    var kind: String
    @Guide(description: "Zero-based column of the top-left corner")
    var col: Int
    @Guide(description: "Zero-based row of the top-left corner")
    var row: Int
    @Guide(description: "How many columns wide")
    var cols: Int
    @Guide(description: "How many rows tall")
    var rows: Int
    @Guide(description: "For data cells: the exact bundleId to bind to. Empty for header.")
    var bundleId: String
    @Guide(description: "For data cells: the exact sliceId to bind to. Empty for header.")
    var sliceId: String
    @Guide(description: "Optional caption or, for header cells, the title text")
    var text: String

    func toCellInput() -> LayoutBlueprintMapper.CellInput {
        LayoutBlueprintMapper.CellInput(
            col: col, row: row, cols: cols, rows: rows,
            kind: kind.lowercased(),
            bundleId: bundleId,
            sliceId: sliceId,
            text: text.isEmpty ? nil : text
        )
    }
}
#endif
