import AppIntents
import WidgetKit
import WidgetForgeKit

/// Configuration intent shared by all four widget kinds. The single parameter
/// picks a saved layout by id from `LayoutStore`.
struct SelectLayoutIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Layout" }
    static var description: IntentDescription {
        IntentDescription("Pick which Widget layout this widget shows.")
    }

    @Parameter(title: "Layout") var layout: LayoutEntity?

    init() {}

    init(layout: LayoutEntity? = nil) {
        self.layout = layout
    }
}

struct LayoutEntity: AppEntity {
    var id: UUID
    var name: String
    var family: LayoutFamily

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Layout" }
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(family.rawValue.capitalized)")
    }

    static let defaultQuery = LayoutQuery()
}

struct LayoutQuery: EntityQuery {
    func entities(for identifiers: [LayoutEntity.ID]) async throws -> [LayoutEntity] {
        LayoutStore().readIndex()
            .filter { identifiers.contains($0.id) }
            .map { LayoutEntity(id: $0.id, name: $0.name, family: $0.family) }
    }

    func suggestedEntities() async throws -> [LayoutEntity] {
        LayoutStore().readIndex().map { LayoutEntity(id: $0.id, name: $0.name, family: $0.family) }
    }

    func defaultResult() async -> LayoutEntity? {
        LayoutStore().readIndex().first.map { LayoutEntity(id: $0.id, name: $0.name, family: $0.family) }
    }
}
