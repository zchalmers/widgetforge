import XCTest
@testable import WidgetForgeKit

final class GalleryContentTests: XCTestCase {
    private let epoch = Date(timeIntervalSince1970: 0)
    private let recent = Date(timeIntervalSince1970: 1_700_000_000)

    private func entry(_ id: UUID, _ family: LayoutFamily, _ name: String, _ updated: Date) -> LayoutStore.IndexEntry {
        LayoutStore.IndexEntry(id: id, name: name, family: family, updatedAt: updated)
    }

    func testUntouchedSeedStaysInBrowseNotYours() {
        let catalog = DefaultLayoutCatalog.all()
        let seed = catalog[0] // an untouched seeded catalog layout
        let index = [entry(seed.id, seed.family, seed.name, epoch)]

        XCTAssertTrue(GalleryContent.yours(index: index).isEmpty)
        XCTAssertTrue(GalleryContent.browse(catalog: catalog, index: index).contains { $0.id == seed.id })
    }

    func testEditedSeedMovesToYoursAndLeavesBrowse() {
        let catalog = DefaultLayoutCatalog.all()
        let seed = catalog[0]
        let index = [entry(seed.id, seed.family, seed.name, recent)]

        XCTAssertTrue(GalleryContent.yours(index: index).contains { $0.id == seed.id })
        XCTAssertFalse(GalleryContent.browse(catalog: catalog, index: index).contains { $0.id == seed.id })
    }

    func testUserCreatedLayoutIsAlwaysYours() {
        let mine = entry(UUID(), .medium, "My Widget", recent)
        let yours = GalleryContent.yours(index: [mine])
        XCTAssertEqual(yours.count, 1)
        XCTAssertEqual(yours.first?.id, mine.id)
    }

    func testFilterBrowseByPersona() {
        let catalog = DefaultLayoutCatalog.all()
        let salesOnly = GalleryContent.filterBrowse(catalog, persona: .sales)
        XCTAssertFalse(salesOnly.isEmpty)
        XCTAssertTrue(salesOnly.allSatisfy { LayoutPersona.persona(forLayoutId: $0.id) == .sales })
        // nil persona = All
        XCTAssertEqual(GalleryContent.filterBrowse(catalog, persona: nil).count, catalog.count)
    }

    func testGroupBrowseByPersonaFollowsBrowseOrder() {
        let catalog = DefaultLayoutCatalog.all()
        let groups = GalleryContent.groupBrowseByPersona(catalog)
        let personas = groups.map(\.persona)
        // groups appear in browseOrder and contain no empty buckets
        XCTAssertEqual(personas, Persona.browseOrder.filter { p in personas.contains(p) })
        XCTAssertTrue(groups.allSatisfy { !$0.layouts.isEmpty })
    }
}
