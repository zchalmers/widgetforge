import Foundation

/// Pure discovery logic for the Gallery tab. Splits saved layouts and the
/// default catalog into "Yours" and "Browse", and filters/groups by persona.
///
/// Because `seedDefaultLayoutsIfNeeded()` writes every catalog layout to disk on
/// first launch with an epoch `updatedAt`, "present in the store" cannot mean
/// "Yours". A catalog layout counts as Yours only once its `updatedAt` differs
/// from the epoch seed value.
public enum GalleryContent {
    /// True for a catalog layout that has never been touched since seeding.
    public static func isUntouchedSeed(_ entry: LayoutStore.IndexEntry) -> Bool {
        LayoutPersona.isCatalogLayout(entry.id) && entry.updatedAt.timeIntervalSince1970 == 0
    }

    /// User-created layouts plus any seeded default the user has since edited.
    public static func yours(index: [LayoutStore.IndexEntry]) -> [LayoutStore.IndexEntry] {
        index.filter { !isUntouchedSeed($0) }
    }

    /// Catalog layouts not yet claimed by Yours (i.e. untouched seeds and any
    /// catalog entry with no store copy at all).
    public static func browse(catalog: [WidgetLayout], index: [LayoutStore.IndexEntry]) -> [WidgetLayout] {
        let claimed = Set(
            index.filter { LayoutPersona.isCatalogLayout($0.id) && $0.updatedAt.timeIntervalSince1970 != 0 }
                 .map(\.id)
        )
        return catalog.filter { !claimed.contains($0.id) }
    }

    /// Filter Yours by persona. `nil` = All. A user-created entry's persona is
    /// `.custom`.
    public static func filterYours(_ entries: [LayoutStore.IndexEntry], persona: Persona?) -> [LayoutStore.IndexEntry] {
        guard let persona else { return entries }
        return entries.filter { LayoutPersona.persona(forLayoutId: $0.id) == persona }
    }

    /// Filter Browse by persona. `nil` = All.
    public static func filterBrowse(_ layouts: [WidgetLayout], persona: Persona?) -> [WidgetLayout] {
        guard let persona else { return layouts }
        return layouts.filter { LayoutPersona.persona(forLayoutId: $0.id) == persona }
    }

    /// Group Browse layouts into persona sections, in `Persona.browseOrder`,
    /// dropping empty buckets.
    public static func groupBrowseByPersona(_ layouts: [WidgetLayout]) -> [(persona: Persona, layouts: [WidgetLayout])] {
        Persona.browseOrder.compactMap { persona in
            let bucket = layouts.filter { LayoutPersona.persona(forLayoutId: $0.id) == persona }
            return bucket.isEmpty ? nil : (persona, bucket)
        }
    }
}
