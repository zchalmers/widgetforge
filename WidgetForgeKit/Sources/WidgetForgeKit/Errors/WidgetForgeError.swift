import Foundation

public enum LayoutFamily: String, Codable, Sendable, CaseIterable, Equatable {
    case small
    case medium
    case large
    case extraLarge
    case xlPortrait

    public var cols: Int {
        switch self {
        case .small: return 2
        case .medium, .large, .extraLarge, .xlPortrait: return 4
        }
    }

    public var rows: Int {
        switch self {
        case .small: return 2
        case .medium: return 2
        case .large: return 4
        case .extraLarge, .xlPortrait: return 6
        }
    }
}

public enum WidgetForgeError: Error, Equatable {
    case containerUnavailable
    case coordinationFailed(underlying: Error)
    case decodeFailed(fileName: String, underlying: Error)
    case schemaTooNew(fileName: String, version: Int)
    case cellOverlap(a: UUID, b: UUID)
    case cellOutOfBounds(cell: UUID, family: LayoutFamily)
    case invalidBinding(reason: String)

    public static func == (lhs: WidgetForgeError, rhs: WidgetForgeError) -> Bool {
        switch (lhs, rhs) {
        case (.containerUnavailable, .containerUnavailable): return true
        case (.coordinationFailed, .coordinationFailed): return true
        case (.decodeFailed(let a, _), .decodeFailed(let b, _)): return a == b
        case (.schemaTooNew(let a, let av), .schemaTooNew(let b, let bv)): return a == b && av == bv
        case (.cellOverlap(let a1, let a2), .cellOverlap(let b1, let b2)): return a1 == b1 && a2 == b2
        case (.cellOutOfBounds(let a, let af), .cellOutOfBounds(let b, let bf)): return a == b && af == bf
        case (.invalidBinding(let a), .invalidBinding(let b)): return a == b
        default: return false
        }
    }
}

public enum RetryAction: Equatable, Sendable {
    case reload
    case openApp(String)
    case openEditor(UUID)
    case openAppsTab
}
