import Foundation

public struct SharedContainer: Sendable {
    public static let defaultAppGroup = "group.com.example.widgetforge.shared"

    public let appGroup: String
    public let overrideURL: URL?

    public init(appGroup: String = SharedContainer.defaultAppGroup) {
        self.appGroup = appGroup
        self.overrideURL = nil
    }

    public init(overrideURL: URL) {
        self.appGroup = ""
        self.overrideURL = overrideURL
    }

    public var containerURL: URL? {
        if let overrideURL { return overrideURL }
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
    }

    public func manifestsDirectoryURL() -> URL? {
        containerURL?.appendingPathComponent("manifests", isDirectory: true)
    }

    public func manifestURL(for bundleId: String) -> URL? {
        manifestsDirectoryURL()?.appendingPathComponent("\(bundleId).json", isDirectory: false)
    }

    public func layoutsDirectoryURL() -> URL? {
        containerURL?.appendingPathComponent("layouts", isDirectory: true)
    }

    public func layoutURL(for id: UUID) -> URL? {
        layoutsDirectoryURL()?.appendingPathComponent("\(id.uuidString).json", isDirectory: false)
    }

    public func layoutIndexURL() -> URL? {
        layoutsDirectoryURL()?.appendingPathComponent("index.json", isDirectory: false)
    }
}
