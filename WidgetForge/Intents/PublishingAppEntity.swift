import Foundation
import WidgetForgeKit
import AppIntents

/// One entity per registered Widget app. Identifier is the app's bundle id.
///
/// `suggestedEntities()` returns apps that either currently publish a manifest
/// or have a KnownSliceCatalog entry, so pre-publish shortcuts still surface.
public struct PublishingAppEntity: AppEntity, Sendable {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Widget App")
    }

    public static let defaultQuery = PublishingAppEntityQuery()

    public var id: String            // bundleId
    public var displayName: String
    public var scheme: String
    public var accentHex: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(displayName)",
            subtitle: "\(scheme):// · accent \(accentHex)"
        )
    }

    public init(entry: AppRegistry.Entry) {
        self.id = entry.bundleId
        self.displayName = entry.displayName
        self.scheme = entry.scheme
        self.accentHex = entry.accentHex
    }

    // TODO iOS 27: add `.appEntityIdentifier(id, for: PublishingAppEntity.self)`
    // view annotation on rows in the Apps list once the annotation API is confirmed.
}

public struct PublishingAppEntityQuery: EntityQuery, EntityStringQuery {
    public init() {}

    public func entities(for identifiers: [PublishingAppEntity.ID]) async throws -> [PublishingAppEntity] {
        let registry = AppRegistry.default
        return identifiers.compactMap { bundleId in
            registry.entry(for: bundleId).map(PublishingAppEntity.init(entry:))
        }
    }

    public func suggestedEntities() async throws -> [PublishingAppEntity] {
        WidgetIntentContext.appSuggestions()
            .map { PublishingAppEntity(entry: $0.entry) }
    }

    public func entities(matching string: String) async throws -> [PublishingAppEntity] {
        let needle = string.lowercased()
        return WidgetIntentContext.appSuggestions()
            .filter { $0.entry.displayName.lowercased().contains(needle) }
            .map { PublishingAppEntity(entry: $0.entry) }
    }

    public func defaultResult() async -> PublishingAppEntity? {
        try? await suggestedEntities().first
    }
}
