import SwiftUI
import WidgetForgeKit
import WidgetKit
import UIKit

@main
struct WidgetForgeApp: App {
    @UIApplicationDelegateAdaptor(WidgetForgeAppDelegate.self) private var appDelegate
    @State private var router = AppRouter()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(router)
                .onOpenURL(perform: router.handle(url:))
                .task {
                    if ConceptRenderer.isRequested {
                        ConceptRenderer.renderAll()
                    }
                    if ThemeRenderer.isRequested {
                        ThemeRenderer.renderAll()
                    }
                    seedDefaultLayoutsIfNeeded()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .onChange(of: scenePhase) { _, phase in
                    // Every foreground triggers a global prune so uninstall
                    // of a peer Widget app propagates even when the user is on a
                    // tab other than "Apps." AppsView also refreshes when it
                    // appears, so its rows will reflect the new state.
                    //
                    // A publisher app's own WidgetCenter.reloadAllTimelines()
                    // only reloads that app's widgets — it cannot refresh THIS
                    // app's widget across the process boundary. So every time
                    // WidgetForge comes to the foreground we re-read the shared
                    // container and force a timeline reload, guaranteeing the
                    // widget reflects the latest manifests published by peers.
                    if phase == .active {
                        pruneUninstalledPublishers()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
        }
    }

    /// Deletes manifests for AppRegistry entries whose URL scheme no longer
    /// resolves via `canOpenURL`. Best-effort: any error is logged upstream by
    /// `AppAvailability.pruneUninstalled`. Reloads WidgetKit timelines when at
    /// least one manifest was removed so the widget flips to its empty state.
    @MainActor
    private func pruneUninstalledPublishers() {
        let store = ManifestStore()
        let probe = UIKitURLSchemeProbe()
        let availability = AppAvailability(registry: .default, manifests: store, probe: probe)
        let results = availability.results()
        let removed = AppAvailability.pruneUninstalled(results: results, store: store)
        if removed > 0 {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// Seeds the persona-tailored default layout catalog so the widget picker
    /// always offers a rich set of ready-to-use layouts across every family.
    ///
    /// Idempotent and keyed on each catalog layout's stable id: a catalog entry
    /// is written only if no layout with that id already exists, so the user's
    /// own layouts and any edits they have made to a seeded default are never
    /// clobbered. New catalog entries added in a future build get seeded on the
    /// next launch without disturbing existing ones.
    private func seedDefaultLayoutsIfNeeded() {
        let store = LayoutStore()
        let index = store.readIndex()

        // One-time cleanup: retire the pre-catalog "Default <family>" seeds
        // (one per family, epoch-stamped) now that the persona catalog supersedes
        // them. A user-renamed or edited layout has a different name or a
        // non-epoch updatedAt, so it is never touched.
        for entry in index where entry.updatedAt.timeIntervalSince1970 == 0
            && entry.name == "Default \(entry.family.rawValue)" {
            try? store.delete(id: entry.id)
        }

        // Seed catalog layouts, and refresh any UNTOUCHED seed whose bindings
        // have changed (e.g. re-pointed to real publisher slices). A seed is
        // "untouched" when its stored updatedAt is still the epoch stamp; a
        // layout the user edited has a real updatedAt and is never overwritten.
        let existing = store.readIndex()
        let epochSeedIds = Set(existing.filter { $0.updatedAt.timeIntervalSince1970 == 0 }.map(\.id))
        let allIds = Set(existing.map(\.id))
        for layout in DefaultLayoutCatalog.all() {
            if !allIds.contains(layout.id) {
                try? store.write(layout)            // new catalog entry
            } else if epochSeedIds.contains(layout.id),
                      let stored = try? store.read(id: layout.id),
                      stored.cells != layout.cells {
                try? store.write(layout)            // untouched seed with stale bindings → refresh
            }
        }
    }
}
