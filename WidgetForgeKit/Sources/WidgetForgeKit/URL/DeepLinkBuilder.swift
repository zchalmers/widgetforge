import Foundation

public enum WidgetKind: String, Sendable, Equatable, CaseIterable {
    case WFSmall, WFMedium, WFLarge, WFXL
}

public enum RecoveryReason: String, Sendable, Equatable, CaseIterable {
    case noManifests
    case missingSlice
    case missingLayout
    case readFailure
    case containerUnreadable
}

public enum DeepLinkBuilder {
    public static let scheme = "widgetforge"

    public static func home() -> URL { URL(string: "\(scheme)://home")! }
    public static func apps() -> URL { URL(string: "\(scheme)://apps")! }
    public static func health() -> URL { URL(string: "\(scheme)://health")! }

    public static func editor(layoutId: UUID, cellId: UUID? = nil) -> URL {
        var comps = URLComponents()
        comps.scheme = scheme
        comps.host = "editor"
        var items = [URLQueryItem(name: "layoutId", value: layoutId.uuidString)]
        if let cellId { items.append(URLQueryItem(name: "cellId", value: cellId.uuidString)) }
        comps.queryItems = items
        return comps.url!
    }

    public static func recover(kind: WidgetKind, reason: RecoveryReason, layoutId: UUID? = nil) -> URL {
        var comps = URLComponents()
        comps.scheme = scheme
        comps.host = "recover"
        var items = [
            URLQueryItem(name: "kind", value: kind.rawValue),
            URLQueryItem(name: "reason", value: reason.rawValue)
        ]
        if let layoutId { items.append(URLQueryItem(name: "layoutId", value: layoutId.uuidString)) }
        comps.queryItems = items
        return comps.url!
    }
}

public struct ParsedRecovery: Equatable, Sendable {
    public let kind: WidgetKind
    public let reason: RecoveryReason
    public let layoutId: UUID?

    public init?(url: URL) {
        guard url.scheme == DeepLinkBuilder.scheme, url.host == "recover" else { return nil }
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = comps.queryItems else { return nil }
        var kindRaw: String?
        var reasonRaw: String?
        var layoutRaw: String?
        for item in items {
            switch item.name {
            case "kind": kindRaw = item.value
            case "reason": reasonRaw = item.value
            case "layoutId": layoutRaw = item.value
            default: break
            }
        }
        guard let kindRaw, let kind = WidgetKind(rawValue: kindRaw) else { return nil }
        guard let reasonRaw, let reason = RecoveryReason(rawValue: reasonRaw) else { return nil }
        self.kind = kind
        self.reason = reason
        if let layoutRaw { self.layoutId = UUID(uuidString: layoutRaw) } else { self.layoutId = nil }
    }
}
