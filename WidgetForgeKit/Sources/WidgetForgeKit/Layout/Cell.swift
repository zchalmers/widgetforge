import Foundation

public struct Cell: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public var origin: GridPoint
    public var span: GridSize
    public var component: Component

    public init(id: UUID = UUID(), origin: GridPoint, span: GridSize, component: Component) {
        self.id = id
        self.origin = origin
        self.span = span
        self.component = component
    }
}
