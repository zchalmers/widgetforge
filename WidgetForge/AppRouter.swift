import SwiftUI
import WidgetForgeKit

/// In-app navigation state. Drives which tab is visible and receives
/// widgetforge:// deep links from the widget extension.
@Observable
final class AppRouter {
    enum Tab: Hashable {
        case gallery, myWidgets, apps, recovery, debug
    }

    var tab: Tab = .myWidgets
    var recoveryContext: RecoveryContext?
    var editorContext: EditorContext?

    struct RecoveryContext: Hashable {
        let kind: WidgetKind
        let reason: RecoveryReason
        let layoutId: UUID?
    }

    struct EditorContext: Hashable {
        let layoutId: UUID
        let cellId: UUID?
    }

    func handle(url: URL) {
        guard url.scheme == DeepLinkBuilder.scheme else { return }
        switch url.host {
        case "home":
            tab = .myWidgets
        case "apps":
            tab = .apps
        case "debug":
            tab = .debug
        case "health":
            tab = .myWidgets
        case "recover":
            if let parsed = ParsedRecovery(url: url) {
                recoveryContext = RecoveryContext(kind: parsed.kind, reason: parsed.reason, layoutId: parsed.layoutId)
                tab = .recovery
            }
        case "editor":
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let layoutStr = comps?.queryItems?.first(where: { $0.name == "layoutId" })?.value ?? ""
            let cellStr = comps?.queryItems?.first(where: { $0.name == "cellId" })?.value
            if let layoutId = UUID(uuidString: layoutStr) {
                editorContext = EditorContext(layoutId: layoutId, cellId: cellStr.flatMap(UUID.init))
                tab = .myWidgets
            }
        default:
            break
        }
    }
}
