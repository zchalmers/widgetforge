import Foundation

public struct WidgetLayout: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var family: LayoutFamily
    public var cells: [Cell]
    public var background: BackgroundStyle
    /// Selected visual theme id (see `ThemeCatalog`). Optional + defaulted so
    /// layouts stored before themes existed decode to nil (classic look).
    public var themeId: String?
    public var createdAt: Date
    public var updatedAt: Date

    public init(id: UUID = UUID(), name: String, family: LayoutFamily,
                cells: [Cell], background: BackgroundStyle,
                themeId: String? = nil,
                createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.family = family
        self.cells = cells
        self.background = background
        self.themeId = themeId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
