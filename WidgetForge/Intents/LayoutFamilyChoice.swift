import Foundation
import WidgetForgeKit
import AppIntents

/// AppEnum wrapping the kit's `LayoutFamily` so it can be an intent parameter.
/// Kept in the app target (AppIntents dependency) rather than the kit.
public enum LayoutFamilyChoice: String, AppEnum {
    case small, medium, large, extraLarge, xlPortrait

    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Widget Size")

    public static let caseDisplayRepresentations: [LayoutFamilyChoice: DisplayRepresentation] = [
        .small: "Small",
        .medium: "Medium",
        .large: "Large",
        .extraLarge: "Extra Large",
        .xlPortrait: "XL Portrait"
    ]

    public var family: LayoutFamily {
        switch self {
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .extraLarge: return .extraLarge
        case .xlPortrait: return .xlPortrait
        }
    }
}
