import WidgetKit
import WidgetForgeKit
import Foundation

/// Timeline provider shared by all four widget kinds. Each widget passes its
/// role so the provider filters `suggestedEntities` and picks the correct
/// default layout if no configuration was chosen.
struct LayoutTimelineProvider: AppIntentTimelineProvider {
    let role: WidgetRole

    func placeholder(in context: Context) -> LayoutEntry {
        LayoutEntry(
            date: .now,
            layout: LayoutStore.defaultLayout(for: role.defaultFamily),
            manifests: SampleData.manifests()
        )
    }

    func snapshot(for configuration: SelectLayoutIntent, in context: Context) async -> LayoutEntry {
        // In the widget gallery (isPreview), fill any not-yet-published apps
        // with sample data so the user can see what the layout does before
        // adding it. A live, configured widget uses only real manifests.
        entry(for: configuration, preview: context.isPreview)
    }

    func timeline(for configuration: SelectLayoutIntent, in context: Context) async -> Timeline<LayoutEntry> {
        let e = entry(for: configuration, preview: false)
        // Re-read the shared container on a short cadence. A publisher app's
        // WidgetCenter.reloadAllTimelines() only reloads its OWN widgets, so it
        // cannot push a refresh into this (separate) app's widget. WidgetForge
        // also force-reloads on every foreground, but between those this timer
        // is the only thing that pulls freshly-published manifests, so keep it
        // tight. iOS still rate-limits actual refreshes by energy budget.
        return Timeline(entries: [e], policy: .after(Date().addingTimeInterval(5 * 60)))
    }

    private func entry(for cfg: SelectLayoutIntent, preview: Bool) -> LayoutEntry {
        let real = ManifestStore().readAll()
        let manifests = preview ? SampleData.merged(withReal: real) : real
        let store = LayoutStore()
        let layout: WidgetLayout = {
            if let picked = cfg.layout, let loaded = try? store.read(id: picked.id) {
                return loaded
            }
            // Fallback to the first index entry that matches this widget's family,
            // else the kit-supplied default for the role.
            let idx = store.readIndex().first(where: { $0.family == role.defaultFamily })
            if let idx, let loaded = try? store.read(id: idx.id) {
                return loaded
            }
            return LayoutStore.defaultLayout(for: role.defaultFamily)
        }()
        return LayoutEntry(date: .now, layout: layout, manifests: manifests)
    }
}

struct LayoutEntry: TimelineEntry {
    let date: Date
    let layout: WidgetLayout
    let manifests: [AppCapabilityManifest]
}
