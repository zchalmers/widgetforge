import Foundation

public extension WidgetForgeError {
    var userTitle: String {
        switch self {
        case .containerUnavailable: return "Widget setup incomplete"
        case .coordinationFailed: return "Couldn't load layout"
        case .decodeFailed: return "Couldn't read a file"
        case .schemaTooNew: return "App update required"
        case .cellOverlap: return "Cells overlap"
        case .cellOutOfBounds: return "Cell is outside the grid"
        case .invalidBinding: return "Binding is not valid"
        }
    }

    var userExplanation: String {
        switch self {
        case .containerUnavailable:
            return "The App Group container is not attached. Reopen WidgetForge to finish setup."
        case .coordinationFailed:
            return "The layout file was busy or unreachable. Try again in a moment."
        case .decodeFailed(let name, _):
            return "The file \(name) could not be decoded. It may be from a newer build; open the Apps tab to check."
        case .schemaTooNew(let name, let v):
            return "The file \(name) uses schema version \(v). Update WidgetForge to read it."
        case .cellOverlap(let a, let b):
            return "Cells \(a.uuidString.prefix(4)) and \(b.uuidString.prefix(4)) share grid coordinates. Move one before saving."
        case .cellOutOfBounds(_, let family):
            return "This cell sits outside the \(family.rawValue) grid. Move it back inside \(family.cols) by \(family.rows)."
        case .invalidBinding(let reason):
            return "This binding is not usable: \(reason). Pick another slice from the Apps tab."
        }
    }

    var userRetryAction: RetryAction? {
        switch self {
        case .containerUnavailable: return .openAppsTab
        case .coordinationFailed: return .reload
        case .decodeFailed: return .reload
        case .schemaTooNew: return .openAppsTab
        case .cellOverlap: return nil        // structural, requires user edit
        case .cellOutOfBounds: return nil    // structural, requires user edit
        case .invalidBinding: return .openAppsTab
        }
    }
}
