import SwiftUI
import WidgetForgeKit
import WidgetKit

@Observable
final class GalleryViewModel {
    var selectedPersona: Persona?
    private(set) var allYours: [LayoutStore.IndexEntry] = []
    private(set) var allBrowse: [WidgetLayout] = []

    /// One shared render context for every card built this load.
    let renderContext: RenderContext

    private let store = LayoutStore()

    init() {
        let manifests = ManifestStore().readAll()
        self.renderContext = RenderContext(
            pool: SlicePool(SampleData.merged(withReal: manifests)),
            registry: .default
        )
    }

    var yours: [LayoutStore.IndexEntry] {
        GalleryContent.filterYours(allYours, persona: selectedPersona)
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var browseGroups: [(persona: Persona, layouts: [WidgetLayout])] {
        let filtered = GalleryContent.filterBrowse(allBrowse, persona: selectedPersona)
        return GalleryContent.groupBrowseByPersona(filtered)
    }

    func refresh() {
        let index = store.readIndex()
        allYours = GalleryContent.yours(index: index)
        allBrowse = GalleryContent.browse(catalog: DefaultLayoutCatalog.all(), index: index)
    }

    func layout(for entry: LayoutStore.IndexEntry) -> WidgetLayout? {
        try? store.read(id: entry.id)
    }
}
