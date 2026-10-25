import Foundation
import WidgetForgeKit
import AppIntents

// MARK: - Open

/// "Open <app>" — hands the user off to the Widget app via its custom scheme.
public struct OpenWidgetAppIntent: AppIntent {
    public static let title: LocalizedStringResource = "Open Widget App"
    public static let description = IntentDescription("Opens a Widget app via its custom URL scheme.")
    public static let openAppWhenRun: Bool = true

    @Parameter(title: "App", requestValueDialog: IntentDialog("Which Widget app?"))
    public var target: PublishingAppEntity

    public init() {}
    public init(target: PublishingAppEntity) { self.target = target }

    public static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$target)")
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let url = URL(string: "\(target.scheme)://")!
        // Hand the URL to the system so it opens the Widget app. On the sim the
        // scheme resolves via LSApplicationQueriesSchemes; on device it opens
        // the installed app or falls back to the App Store.
        await UIApplicationOpener.open(url)
        return .result(dialog: IntentDialog("Opening \(target.displayName)."))
    }
}

// MARK: - Refresh

/// "Refresh <app>" — deep-links into the app to trigger a fresh publish,
/// waits briefly, and returns the updated dialog.
public struct RefreshWidgetAppIntent: AppIntent {
    public static let title: LocalizedStringResource = "Refresh Widget App"
    public static let description = IntentDescription("Deep-links into a Widget app to trigger a fresh manifest publish.")
    public static let openAppWhenRun: Bool = false

    @Parameter(title: "App", requestValueDialog: IntentDialog("Which Widget app?"))
    public var app: PublishingAppEntity

    public init() {}
    public init(app: PublishingAppEntity) { self.app = app }

    public static var parameterSummary: some ParameterSummary {
        Summary("Refresh \(\.$app)")
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        // Nudge the app to republish via a well-known deep-link path. The
        // recipient bridge listens for /refresh and writes a new manifest.
        if let url = URL(string: "\(app.scheme)://refresh") {
            await UIApplicationOpener.open(url)
        }
        // Brief settle window; the recipient app writes into the shared container.
        try? await Task.sleep(nanoseconds: 800_000_000)

        let latest = WidgetIntentContext.snapshot(for: app.id, kind: .count)
        let text = latest.map { WidgetIntentContext.spokenDialog(for: $0) } ??
            "Requested a refresh from \(app.displayName)."
        return .result(dialog: IntentDialog("\(text)"))
    }
}

// iOS 27 refinement: opt into LongRunningIntent so the system can keep showing
// progress while the app is suspended.
// [UNCERTAIN] exact protocol name / requirements — guarded so a build against
// an SDK missing the symbol still compiles by dropping this file's tail.
#if compiler(>=6.2)
@available(iOS 27.0, *)
extension RefreshWidgetAppIntent {
    // If the LongRunningIntent protocol lands as expected, add:
    //   extension RefreshWidgetAppIntent: LongRunningIntent { ... }
    // Kept as a no-op comment here to avoid inventing a symbol.
}
#endif

// MARK: - UIKit shim

@MainActor
enum UIApplicationOpener {
    static func open(_ url: URL) async {
#if canImport(UIKit)
        _ = await UIApplication.shared.open(url, options: [:])
#endif
    }
}

#if canImport(UIKit)
import UIKit
#endif
