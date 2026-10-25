import SwiftUI
import WidgetForgeKit
import ThemeKitSwiftUICore
import ThemeKitThemeManager

/// Renders the recovery context set by AppRouter when a widget deep-links back.
/// When there is no context, shows an empty state instructing the user to add
/// a widget from the Home Screen.
struct RecoveryView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        NavigationStack {
            Group {
                if let ctx = router.recoveryContext {
                    RecoveryDetail(context: ctx)
                } else {
                    IllustratedMessage(
                        detailImage: Image(systemName: "checkmark.seal"),
                        title: AttributedString("No Alerts"),
                        description: AttributedString("When a widget hits an error it will deep-link here with details."),
                        detailImageSize: .large,
                        contentAlignment: .center
                    )
                    .padding()
                }
            }
            .navigationTitle("Alerts")
        }
    }
}

private struct RecoveryDetail: View {
    let context: AppRouter.RecoveryContext
    @Environment(AppRouter.self) private var router

    var body: some View {
        IllustratedMessage(
            detailImage: Image(systemName: symbol),
            title: AttributedString(headline),
            description: AttributedString(explanation),
            action: ThemeKitButton(title: "Dismiss") { _ in
                router.recoveryContext = nil
                router.tab = .myWidgets
            },
            detailImageSize: .large,
            contentAlignment: .center
        )
        .detailImageStyle { config in
            config.detailImage
                .font(.system(size: 48))
                .foregroundStyle(tint)
        }
        .padding()
    }

    private var symbol: String {
        switch context.reason {
        case .noManifests: return "square.stack.3d.up.slash"
        case .missingSlice: return "questionmark.folder"
        case .missingLayout: return "rectangle.dashed"
        case .readFailure: return "exclamationmark.triangle.fill"
        case .containerUnreadable: return "lock.slash"
        }
    }

    private var tint: Color {
        switch context.reason {
        case .noManifests, .missingSlice, .missingLayout: return DesignSystem.emptyStateTint
        case .readFailure, .containerUnreadable: return DesignSystem.errorStateTint
        }
    }

    private var headline: String {
        switch context.reason {
        case .noManifests: return "No apps publishing yet"
        case .missingSlice: return "That slice isn't available"
        case .missingLayout: return "Layout was removed"
        case .readFailure: return "Couldn't load your widget"
        case .containerUnreadable: return "Shared container blocked"
        }
    }

    private var explanation: String {
        switch context.reason {
        case .noManifests:
            return "Open a Widget app (Inbox, Pipeline) at least once so it can publish data to WidgetForge."
        case .missingSlice:
            return "The bound data slice hasn't been published yet. Open the source app to refresh."
        case .missingLayout:
            return "The layout this widget pointed at was deleted. Long-press the widget and pick a new one."
        case .readFailure:
            return "WidgetForge couldn't read its shared storage. Reopen the app and try again."
        case .containerUnreadable:
            return "Check that the App Group entitlement is present. This is a build-configuration issue."
        }
    }
}
