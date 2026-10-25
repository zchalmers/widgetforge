import Foundation

public enum SliceValue: Codable, Sendable, Equatable {
    case count(Int)
    case list([ListItem])
    case metric(Double, unit: String?, trend: Trend?)
    case status(Status, text: String)
    case progress(Double, label: String)

    public struct ListItem: Codable, Sendable, Equatable, Identifiable {
        public let id: String
        public let title: String
        public let subtitle: String?
        public let timestamp: Date?
        public let deepLink: URL?
        public init(id: String, title: String, subtitle: String? = nil, timestamp: Date? = nil, deepLink: URL? = nil) {
            self.id = id; self.title = title; self.subtitle = subtitle; self.timestamp = timestamp; self.deepLink = deepLink
        }
    }

    public enum Trend: String, Codable, Sendable, Equatable { case up, down, flat }
    public enum Status: String, Codable, Sendable, Equatable { case ok, warning, critical }

    public var kind: SliceKind {
        switch self {
        case .count: return .count
        case .list: return .list
        case .metric: return .metric
        case .status: return .status
        case .progress: return .progress
        }
    }

    // MARK: - Codable
    private enum CodingKeys: String, CodingKey { case type, payload }

    private struct MetricPayload: Codable, Equatable {
        let value: Double
        let unit: String?
        let trend: Trend?
    }
    private struct StatusPayload: Codable, Equatable {
        let status: Status
        let text: String
    }
    private struct ProgressPayload: Codable, Equatable {
        let value: Double
        let label: String
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .count(let n):
            try c.encode("count", forKey: .type)
            try c.encode(n, forKey: .payload)
        case .list(let items):
            try c.encode("list", forKey: .type)
            try c.encode(items, forKey: .payload)
        case .metric(let v, let unit, let trend):
            try c.encode("metric", forKey: .type)
            try c.encode(MetricPayload(value: v, unit: unit, trend: trend), forKey: .payload)
        case .status(let s, let text):
            try c.encode("status", forKey: .type)
            try c.encode(StatusPayload(status: s, text: text), forKey: .payload)
        case .progress(let v, let label):
            try c.encode("progress", forKey: .type)
            try c.encode(ProgressPayload(value: v, label: label), forKey: .payload)
        }
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try c.decode(String.self, forKey: .type)
        switch discriminator {
        case "count":
            self = .count(try c.decode(Int.self, forKey: .payload))
        case "list":
            self = .list(try c.decode([ListItem].self, forKey: .payload))
        case "metric":
            let p = try c.decode(MetricPayload.self, forKey: .payload)
            self = .metric(p.value, unit: p.unit, trend: p.trend)
        case "status":
            let p = try c.decode(StatusPayload.self, forKey: .payload)
            self = .status(p.status, text: p.text)
        case "progress":
            let p = try c.decode(ProgressPayload.self, forKey: .payload)
            self = .progress(p.value, label: p.label)
        default:
            throw WFDecodeError.unknownDiscriminator(discriminator)
        }
    }
}
