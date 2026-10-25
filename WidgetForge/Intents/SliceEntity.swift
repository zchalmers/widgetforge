import Foundation
import WidgetForgeKit
import AppIntents

/// One entity per (bundleId, sliceId) pair. Identifier is 'bundleId|sliceId'.
public struct SliceEntity: AppEntity, Sendable {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Widget Slice")
    }

    public static let defaultQuery = SliceEntityQuery()

    public var id: String            // "bundleId|sliceId"
    public var bundleId: String
    public var sliceId: String
    public var sliceDisplayName: String
    public var appDisplayName: String
    public var kindRaw: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(sliceDisplayName)",
            subtitle: "\(appDisplayName) · \(kindRaw)"
        )
    }

    public init(bundleId: String, sliceId: String, sliceDisplayName: String, appDisplayName: String, kind: SliceKind) {
        self.bundleId = bundleId
        self.sliceId = sliceId
        self.sliceDisplayName = sliceDisplayName
        self.appDisplayName = appDisplayName
        self.kindRaw = kind.rawValue
        self.id = "\(bundleId)|\(sliceId)"
    }

    static func decode(id: String) -> (bundleId: String, sliceId: String)? {
        let parts = id.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return nil }
        return (String(parts[0]), String(parts[1]))
    }
}

public struct SliceEntityQuery: EntityQuery, EntityStringQuery {
    public init() {}

    public func entities(for identifiers: [SliceEntity.ID]) async throws -> [SliceEntity] {
        let suggestions = WidgetIntentContext.sliceSuggestions()
        let byId: [String: WidgetIntentContext.SliceSuggestion] = Dictionary(uniqueKeysWithValues:
            suggestions.map { ("\($0.entry.bundleId)|\($0.sliceId)", $0) })
        return identifiers.compactMap { id in
            guard let s = byId[id] else { return nil }
            return SliceEntity(bundleId: s.entry.bundleId,
                               sliceId: s.sliceId,
                               sliceDisplayName: s.sliceDisplayName,
                               appDisplayName: s.entry.displayName,
                               kind: s.kind)
        }
    }

    public func suggestedEntities() async throws -> [SliceEntity] {
        WidgetIntentContext.sliceSuggestions().map { s in
            SliceEntity(bundleId: s.entry.bundleId,
                        sliceId: s.sliceId,
                        sliceDisplayName: s.sliceDisplayName,
                        appDisplayName: s.entry.displayName,
                        kind: s.kind)
        }
    }

    public func entities(matching string: String) async throws -> [SliceEntity] {
        let needle = string.lowercased()
        return try await suggestedEntities().filter {
            $0.sliceDisplayName.lowercased().contains(needle) ||
            $0.appDisplayName.lowercased().contains(needle)
        }
    }

    public func defaultResult() async -> SliceEntity? {
        try? await suggestedEntities().first
    }
}
