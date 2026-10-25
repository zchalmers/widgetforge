import XCTest
@testable import WidgetForgeKit

final class LayoutPersonaTests: XCTestCase {
    func testEveryCatalogLayoutResolvesToNonCustomPersona() {
        for layout in DefaultLayoutCatalog.all() {
            let persona = LayoutPersona.persona(forLayoutId: layout.id)
            XCTAssertNotEqual(persona, .custom, "\(layout.name) (\(layout.family)) should map to a persona")
            XCTAssertTrue(LayoutPersona.isCatalogLayout(layout.id))
        }
    }

    func testUnknownIdResolvesToCustom() {
        let random = UUID()
        XCTAssertEqual(LayoutPersona.persona(forLayoutId: random), .custom)
        XCTAssertFalse(LayoutPersona.isCatalogLayout(random))
    }

    func testKnownMappings() {
        let brief = DefaultLayoutCatalog.id(family: .large, name: "Manager Morning Brief")
        XCTAssertEqual(LayoutPersona.persona(forLayoutId: brief), .manager)
        let exec = DefaultLayoutCatalog.id(family: .extraLarge, name: "Exec Command Center")
        XCTAssertEqual(LayoutPersona.persona(forLayoutId: exec), .exec)
        let feed = DefaultLayoutCatalog.id(family: .xlPortrait, name: "Recognition Feed")
        XCTAssertEqual(LayoutPersona.persona(forLayoutId: feed), .culture)
    }

    func testBrowseOrderExcludesCustom() {
        XCTAssertFalse(Persona.browseOrder.contains(.custom))
        XCTAssertEqual(Set(Persona.browseOrder).count, Persona.browseOrder.count)
    }
}
