import Foundation

public struct CountConfig: Codable, Sendable, Equatable {
    public var binding: DataBinding
    public var caption: String?
    public var accent: AccentChoice
    public init(binding: DataBinding, caption: String?, accent: AccentChoice) {
        self.binding = binding; self.caption = caption; self.accent = accent
    }
}

public struct ListConfig: Codable, Sendable, Equatable {
    public var binding: DataBinding
    public var maxRows: Int
    public var accent: AccentChoice
    public init(binding: DataBinding, maxRows: Int, accent: AccentChoice) {
        self.binding = binding; self.maxRows = maxRows; self.accent = accent
    }
}

public struct MetricConfig: Codable, Sendable, Equatable {
    public var binding: DataBinding
    public var caption: String?
    public var accent: AccentChoice
    public init(binding: DataBinding, caption: String?, accent: AccentChoice) {
        self.binding = binding; self.caption = caption; self.accent = accent
    }
}

public struct StatusConfig: Codable, Sendable, Equatable {
    public var binding: DataBinding
    public var accent: AccentChoice
    public init(binding: DataBinding, accent: AccentChoice) {
        self.binding = binding; self.accent = accent
    }
}

public struct ProgressConfig: Codable, Sendable, Equatable {
    public var binding: DataBinding
    public var style: ProgressStyle
    public var accent: AccentChoice
    public init(binding: DataBinding, style: ProgressStyle, accent: AccentChoice) {
        self.binding = binding; self.style = style; self.accent = accent
    }
}

public struct HeaderConfig: Codable, Sendable, Equatable {
    public var title: String
    public var subtitle: String?
    public var accent: AccentChoice
    public init(title: String, subtitle: String?, accent: AccentChoice) {
        self.title = title; self.subtitle = subtitle; self.accent = accent
    }
}

public struct AppTileConfig: Codable, Sendable, Equatable {
    public var bundleId: String
    public var accent: AccentChoice
    public init(bundleId: String, accent: AccentChoice) {
        self.bundleId = bundleId; self.accent = accent
    }
}

public enum Component: Codable, Sendable, Equatable {
    case count(CountConfig)
    case list(ListConfig)
    case metric(MetricConfig)
    case status(StatusConfig)
    case progress(ProgressConfig)
    case header(HeaderConfig)
    case appTile(AppTileConfig)

    public enum Kind: String, Codable, Sendable, CaseIterable {
        case count, list, metric, status, progress, header, appTile
    }

    public var kind: Kind {
        switch self {
        case .count: return .count
        case .list: return .list
        case .metric: return .metric
        case .status: return .status
        case .progress: return .progress
        case .header: return .header
        case .appTile: return .appTile
        }
    }

    public var requiredSliceKind: SliceKind? {
        switch self {
        case .count: return .count
        case .list: return .list
        case .metric: return .metric
        case .status: return .status
        case .progress: return .progress
        case .header, .appTile: return nil
        }
    }

    private enum CodingKeys: String, CodingKey { case type, payload }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(kind.rawValue, forKey: .type)
        switch self {
        case .count(let x): try c.encode(x, forKey: .payload)
        case .list(let x): try c.encode(x, forKey: .payload)
        case .metric(let x): try c.encode(x, forKey: .payload)
        case .status(let x): try c.encode(x, forKey: .payload)
        case .progress(let x): try c.encode(x, forKey: .payload)
        case .header(let x): try c.encode(x, forKey: .payload)
        case .appTile(let x): try c.encode(x, forKey: .payload)
        }
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(String.self, forKey: .type)
        switch type {
        case "count": self = .count(try c.decode(CountConfig.self, forKey: .payload))
        case "list": self = .list(try c.decode(ListConfig.self, forKey: .payload))
        case "metric": self = .metric(try c.decode(MetricConfig.self, forKey: .payload))
        case "status": self = .status(try c.decode(StatusConfig.self, forKey: .payload))
        case "progress": self = .progress(try c.decode(ProgressConfig.self, forKey: .payload))
        case "header": self = .header(try c.decode(HeaderConfig.self, forKey: .payload))
        case "appTile": self = .appTile(try c.decode(AppTileConfig.self, forKey: .payload))
        default: throw WFDecodeError.unknownDiscriminator(type)
        }
    }
}
