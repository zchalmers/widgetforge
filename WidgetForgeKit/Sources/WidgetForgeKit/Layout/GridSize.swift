import Foundation

public struct GridPoint: Codable, Sendable, Hashable {
    public var col: Int
    public var row: Int
    public init(col: Int, row: Int) { self.col = col; self.row = row }
}

public struct GridSize: Codable, Sendable, Hashable {
    public var cols: Int
    public var rows: Int
    public init(cols: Int, rows: Int) { self.cols = cols; self.rows = rows }
}

public enum ProgressStyle: String, Codable, Sendable, Equatable {
    case ring
    case bar
}

public enum AccentChoice: Codable, Sendable, Equatable {
    case fromApp
    case token(Token)

    public enum Token: String, Codable, Sendable, Equatable, CaseIterable {
        case amber, teal, violet, mint, coral
    }

    private enum CodingKeys: String, CodingKey { case kind, token }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(String.self, forKey: .kind)
        switch kind {
        case "fromApp": self = .fromApp
        case "token": self = .token(try c.decode(Token.self, forKey: .token))
        default: throw WFDecodeError.unknownDiscriminator(kind)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .fromApp: try c.encode("fromApp", forKey: .kind)
        case .token(let t):
            try c.encode("token", forKey: .kind)
            try c.encode(t, forKey: .token)
        }
    }
}

public enum BackgroundStyle: Codable, Sendable, Equatable {
    case system
    case accentHex(String)
    case clear

    private enum CodingKeys: String, CodingKey { case kind, hex }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .kind) {
        case "system": self = .system
        case "clear": self = .clear
        case "accentHex": self = .accentHex(try c.decode(String.self, forKey: .hex))
        case let other: throw WFDecodeError.unknownDiscriminator(other)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .system: try c.encode("system", forKey: .kind)
        case .clear: try c.encode("clear", forKey: .kind)
        case .accentHex(let h):
            try c.encode("accentHex", forKey: .kind)
            try c.encode(h, forKey: .hex)
        }
    }
}
