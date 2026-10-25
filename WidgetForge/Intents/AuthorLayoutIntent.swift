import Foundation
import WidgetForgeKit
import AppIntents
import WidgetKit

/// "Make a Widget widget: <prompt>" — speaks a widget layout into existence.
/// Generation logic lives in `WidgetForgeKit.LayoutAuthor`, shared with the
/// in-app "Describe it with AI" flow.
public struct AuthorLayoutIntent: AppIntent {
    public static let title: LocalizedStringResource = "Make a Widget Widget"
    public static let description = IntentDescription("Describe a widget and WidgetForge builds it from your Widget apps' data.")

    @Parameter(title: "Describe the widget", requestValueDialog: IntentDialog("What should the widget show?"))
    public var prompt: String

    @Parameter(title: "Size", default: .medium)
    public var size: LayoutFamilyChoice

    public init() {}
    public init(prompt: String, size: LayoutFamilyChoice = .medium) {
        self.prompt = prompt
        self.size = size
    }

    public static var parameterSummary: some ParameterSummary {
        Summary("Make a \(\.$size) Widget widget: \(\.$prompt)")
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let family = size.family

        switch LayoutAuthor.availability() {
        case .available:
            if #available(iOS 26.0, *),
               let layout = await LayoutAuthor.generate(prompt: prompt, family: family) {
                try? LayoutStore().write(layout)
                WidgetCenter.shared.reloadAllTimelines()
                return .result(dialog: IntentDialog("Built \"\(layout.name)\" — \(layout.cells.count) cells. Find it in WidgetForge."))
            }
            return .result(dialog: IntentDialog("\(seedFallback(family: family))"))
        case .unsupported:
            return .result(dialog: IntentDialog("\(seedFallback(family: family, prefix: "Building a widget from a description needs Apple Intelligence, which this device doesn't support. "))"))
        case .unavailable:
            return .result(dialog: IntentDialog("\(seedFallback(family: family))"))
        }
    }

    private func seedFallback(family: LayoutFamily, prefix: String = "") -> String {
        let layout = LayoutAuthor.seedDefault(family: family)
        try? LayoutStore().write(layout)
        WidgetCenter.shared.reloadAllTimelines()
        return "\(prefix)Created the default \(family.rawValue) layout instead — open WidgetForge to customize it."
    }
}
