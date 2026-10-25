import Foundation

public struct ManifestStore: Sendable {
    public let container: SharedContainer

    public init(container: SharedContainer = SharedContainer()) {
        self.container = container
    }

    // MARK: - Public API

    public func write(_ manifest: AppCapabilityManifest) throws {
        guard let dir = container.manifestsDirectoryURL(),
              let url = container.manifestURL(for: manifest.bundleId) else {
            throw WidgetForgeError.containerUnavailable
        }
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let data: Data
        do { data = try Self.encoder.encode(manifest) }
        catch { throw WidgetForgeError.coordinationFailed(underlying: error) }
        try Self.coordinatedWrite(data: data, to: url)
    }

    public func readAll() -> [AppCapabilityManifest] {
        guard let dir = container.manifestsDirectoryURL(),
              let contents = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {
            return []
        }
        var out: [AppCapabilityManifest] = []
        for url in contents where url.pathExtension == "json" {
            if let m = decodeSafely(url: url) { out.append(m) }
        }
        return out
    }

    public func read(bundleId: String) -> AppCapabilityManifest? {
        guard let url = container.manifestURL(for: bundleId) else { return nil }
        return decodeSafely(url: url)
    }

    public func remove(bundleId: String) throws {
        guard let url = container.manifestURL(for: bundleId) else {
            throw WidgetForgeError.containerUnavailable
        }
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordError: NSError?
        coordinator.coordinate(writingItemAt: url, options: .forDeleting, error: &coordError) { fileURL in
            try? FileManager.default.removeItem(at: fileURL)
        }
        if let coordError { throw WidgetForgeError.coordinationFailed(underlying: coordError) }
    }

    public func refreshedAt(bundleId: String) -> Date? {
        read(bundleId: bundleId)?.refreshedAt
    }

    // MARK: - Internals

    private func decodeSafely(url: URL) -> AppCapabilityManifest? {
        var data: Data?
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordError: NSError?
        coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &coordError) { readURL in
            data = try? Data(contentsOf: readURL)
        }
        guard let data else { return nil }
        do {
            let manifest = try Self.decoder.decode(AppCapabilityManifest.self, from: data)
            if manifest.schemaVersion > AppCapabilityManifest.currentSchemaVersion {
                WFLog.store.info("skipping manifest with newer schema: \(url.lastPathComponent, privacy: .public) v\(manifest.schemaVersion)")
                return nil
            }
            return manifest
        } catch {
            WFLog.store.error("manifest decode failed: \(url.lastPathComponent, privacy: .public) \(String(describing: error), privacy: .public)")
            return nil
        }
    }

    private static func coordinatedWrite(data: Data, to url: URL) throws {
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordError: NSError?
        var innerError: Error?
        coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &coordError) { writeURL in
            do {
                var opts: Data.WritingOptions = [.atomic]
                #if os(iOS) || os(tvOS) || os(watchOS)
                opts.insert(.completeFileProtectionUntilFirstUserAuthentication)
                #endif
                try data.write(to: writeURL, options: opts)
            } catch {
                innerError = error
            }
        }
        if let coordError { throw WidgetForgeError.coordinationFailed(underlying: coordError) }
        if let innerError { throw WidgetForgeError.coordinationFailed(underlying: innerError) }
    }

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.sortedKeys]
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
