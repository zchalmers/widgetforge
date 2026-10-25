import Foundation
import WidgetForgeKit
import AppIntents

/// AppShortcutsProvider. Compiled at build time by the App Intents metadata
/// extractor. Every phrase MUST contain \(.applicationName). Limits:
///   - up to 10 AppShortcuts per provider,
///   - up to 10 phrases per AppShortcut.
///
/// AppShortcutsBuilder rejects `for`-loop-generated children, and phrase
/// literals must be pure string constants at extract time. This file hard-codes
/// one AppShortcut per deduped Widget app (Inbox, Pipeline, DealApproval)
/// so the metadata extractor accepts every phrase.
public struct WidgetShortcuts: AppShortcutsProvider {

    public static let shortcutTileColor: ShortcutTileColor = .lightBlue

    @AppShortcutsBuilder
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SummarizeWidgetIntent(),
            phrases: [
                "Summarize Widget in \(.applicationName)",
                "Summarize my Widget apps in \(.applicationName)",
                "What's happening in my Widget apps in \(.applicationName)"
            ],
            shortTitle: "Summarize Widget",
            systemImageName: "sparkles"
        )

        AppShortcut(
            intent: ShowWidgetCountIntent(),
            phrases: [
                "How many pending in Inbox in \(.applicationName)",
                "Pending approvals in \(.applicationName)",
                "Show my approvals queue in \(.applicationName)"
            ],
            shortTitle: "Inbox Count",
            systemImageName: "checkmark.seal.fill"
        )

        AppShortcut(
            intent: ShowWidgetListIntent(),
            phrases: [
                "Show my Inbox list in \(.applicationName)",
                "Top approvals in \(.applicationName)",
                "What approvals are pending in \(.applicationName)"
            ],
            shortTitle: "Top Approvals",
            systemImageName: "list.bullet.rectangle"
        )

        AppShortcut(
            intent: ShowWidgetMetricIntent(),
            phrases: [
                "Show my pipeline in \(.applicationName)",
                "Pipeline value in \(.applicationName)",
                "How much is my pipeline in \(.applicationName)"
            ],
            shortTitle: "Pipeline Value",
            systemImageName: "chart.line.uptrend.xyaxis"
        )

        AppShortcut(
            intent: ShowWidgetCountIntent(),
            phrases: [
                "How many deal approvals in \(.applicationName)",
                "Pending deal approvals in \(.applicationName)"
            ],
            shortTitle: "Review Queues Count",
            systemImageName: "signature"
        )

        AppShortcut(
            intent: AskWidgetIntent(),
            phrases: [
                "Ask Widget in \(.applicationName)",
                "What needs my attention in \(.applicationName)",
                "What's going on across Widget in \(.applicationName)"
            ],
            shortTitle: "Ask Widget",
            systemImageName: "questionmark.bubble"
        )

        AppShortcut(
            intent: AuthorLayoutIntent(),
            phrases: [
                "Make a Widget widget in \(.applicationName)",
                "Build a widget in \(.applicationName)",
                "Create a Widget widget in \(.applicationName)"
            ],
            shortTitle: "Make a Widget",
            systemImageName: "wand.and.stars"
        )
    }
}
