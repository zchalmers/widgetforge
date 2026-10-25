import Foundation

public struct LayoutStore: Sendable {
    public let container: SharedContainer

    public struct IndexEntry: Codable, Sendable, Identifiable, Equatable {
        public let id: UUID
        public let name: String
        public let family: LayoutFamily
        public let updatedAt: Date
        public init(id: UUID, name: String, family: LayoutFamily, updatedAt: Date) {
            self.id = id; self.name = name; self.family = family; self.updatedAt = updatedAt
        }
    }

    public init(container: SharedContainer = SharedContainer()) {
        self.container = container
    }

    // MARK: - Write

    public func write(_ layout: WidgetLayout) throws {
        try LayoutValidator.validate(layout)
        guard let dir = container.layoutsDirectoryURL(),
              let file = container.layoutURL(for: layout.id) else {
            throw WidgetForgeError.containerUnavailable
        }
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let data: Data
        do { data = try Self.encoder.encode(layout) }
        catch { throw WidgetForgeError.coordinationFailed(underlying: error) }
        try Self.coordinatedWrite(data: data, to: file)
        try rewriteIndex()
    }

    // MARK: - Read

    public func read(id: UUID) throws -> WidgetLayout {
        guard let url = container.layoutURL(for: id) else {
            throw WidgetForgeError.containerUnavailable
        }
        var readData: Data?
        var coordErr: NSError?
        NSFileCoordinator(filePresenter: nil).coordinate(readingItemAt: url, options: .withoutChanges, error: &coordErr) { readURL in
            readData = try? Data(contentsOf: readURL)
        }
        if let coordErr { throw WidgetForgeError.coordinationFailed(underlying: coordErr) }
        guard let data = readData else {
            throw WidgetForgeError.decodeFailed(fileName: url.lastPathComponent,
                                                underlying: NSError(domain: "WidgetForgeKit", code: 1))
        }
        do {
            return try Self.decoder.decode(WidgetLayout.self, from: data)
        } catch {
            throw WidgetForgeError.decodeFailed(fileName: url.lastPathComponent, underlying: error)
        }
    }

    public func readIndex() -> [IndexEntry] {
        guard let url = container.layoutIndexURL() else { return [] }
        var readData: Data?
        var coordErr: NSError?
        NSFileCoordinator(filePresenter: nil).coordinate(readingItemAt: url, options: .withoutChanges, error: &coordErr) { readURL in
            readData = try? Data(contentsOf: readURL)
        }
        guard let data = readData else { return [] }
        return (try? Self.decoder.decode([IndexEntry].self, from: data)) ?? []
    }

    // MARK: - Delete

    public func delete(id: UUID) throws {
        guard let file = container.layoutURL(for: id) else {
            throw WidgetForgeError.containerUnavailable
        }
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordError: NSError?
        coordinator.coordinate(writingItemAt: file, options: .forDeleting, error: &coordError) { url in
            try? FileManager.default.removeItem(at: url)
        }
        if let coordError { throw WidgetForgeError.coordinationFailed(underlying: coordError) }
        try rewriteIndex()
    }

    // MARK: - Default layouts

    /// Bundle id of the reference publisher used for the seeded layouts.
    /// Matches Inbox's Debug bundle identifier / `AppRegistry.default`.
    private static let seedBundleId = "com.example.it.inbox"
    private static let seedPendingCountSliceId = "pendingCount"
    private static let seedTopListSliceId = "topApprovals"
    private static let seedStatusSliceId = "approvalStatus"

    /// Family-specific seeded layouts. Each ships with a real data binding to
    /// the Inbox reference publisher so the widget renders live data as
    /// soon as any manifest arrives. If Inbox has not published yet, each
    /// leaf renders its own empty-state ("–", "No items", "No signal"). The
    /// user can rebind cells to a different app via the editor.
    public static func defaultLayout(for family: LayoutFamily) -> WidgetLayout {
        let cells: [Cell]
        switch family {
        case .small:
            cells = smallCells()
        case .medium:
            cells = mediumCells()
        case .large:
            cells = largeCells()
        case .extraLarge:
            cells = extraLargeCells()
        case .xlPortrait:
            cells = xlPortraitCells()
        }
        return WidgetLayout(
            name: "Default \(family.rawValue)",
            family: family,
            cells: cells,
            background: .system,
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0)
        )
    }

    private static func pendingCountBinding() -> DataBinding {
        DataBinding(bundleId: seedBundleId, sliceId: seedPendingCountSliceId)
    }
    private static func topListBinding() -> DataBinding {
        DataBinding(bundleId: seedBundleId, sliceId: seedTopListSliceId)
    }
    private static func statusBinding() -> DataBinding {
        DataBinding(bundleId: seedBundleId, sliceId: seedStatusSliceId)
    }

    // 2 cols x 2 rows. Header row + one full-width count.
    private static func smallCells() -> [Cell] {
        [
            Cell(origin: GridPoint(col: 0, row: 0),
                 span: GridSize(cols: 2, rows: 1),
                 component: .header(HeaderConfig(title: "WidgetForge", subtitle: "Small", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 1),
                 span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: pendingCountBinding(),
                                               caption: "Pending",
                                               accent: .fromApp)))
        ]
    }

    // 4 cols x 2 rows. Header top; count + status side by side.
    private static func mediumCells() -> [Cell] {
        [
            Cell(origin: GridPoint(col: 0, row: 0),
                 span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "WidgetForge", subtitle: "Medium", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 1),
                 span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: pendingCountBinding(),
                                               caption: "Pending",
                                               accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1),
                 span: GridSize(cols: 2, rows: 1),
                 component: .status(StatusConfig(binding: statusBinding(),
                                                 accent: .fromApp)))
        ]
    }

    // 4 cols x 4 rows. Header, count+status row, then a 4x2 list.
    private static func largeCells() -> [Cell] {
        [
            Cell(origin: GridPoint(col: 0, row: 0),
                 span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "WidgetForge", subtitle: "Large", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 1),
                 span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: pendingCountBinding(),
                                               caption: "Pending",
                                               accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1),
                 span: GridSize(cols: 2, rows: 1),
                 component: .status(StatusConfig(binding: statusBinding(),
                                                 accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2),
                 span: GridSize(cols: 4, rows: 2),
                 component: .list(ListConfig(binding: topListBinding(),
                                             maxRows: 4,
                                             accent: .fromApp)))
        ]
    }

    // 4 cols x 6 rows. Header + count/status + section header + tall list.
    private static func extraLargeCells() -> [Cell] {
        [
            Cell(origin: GridPoint(col: 0, row: 0),
                 span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "WidgetForge", subtitle: "Extra Large", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 1),
                 span: GridSize(cols: 2, rows: 1),
                 component: .count(CountConfig(binding: pendingCountBinding(),
                                               caption: "Pending approvals",
                                               accent: .fromApp))),
            Cell(origin: GridPoint(col: 2, row: 1),
                 span: GridSize(cols: 2, rows: 1),
                 component: .status(StatusConfig(binding: statusBinding(),
                                                 accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2),
                 span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "Top approvals", subtitle: nil, accent: .token(.amber)))),
            Cell(origin: GridPoint(col: 0, row: 3),
                 span: GridSize(cols: 4, rows: 3),
                 component: .list(ListConfig(binding: topListBinding(),
                                             maxRows: 5,
                                             accent: .fromApp)))
        ]
    }

    // 4 cols x 6 rows portrait. Header, count row, status row, list.
    private static func xlPortraitCells() -> [Cell] {
        [
            Cell(origin: GridPoint(col: 0, row: 0),
                 span: GridSize(cols: 4, rows: 1),
                 component: .header(HeaderConfig(title: "WidgetForge", subtitle: "XL Portrait", accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 1),
                 span: GridSize(cols: 4, rows: 1),
                 component: .count(CountConfig(binding: pendingCountBinding(),
                                               caption: "Pending approvals",
                                               accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 2),
                 span: GridSize(cols: 4, rows: 1),
                 component: .status(StatusConfig(binding: statusBinding(),
                                                 accent: .fromApp))),
            Cell(origin: GridPoint(col: 0, row: 3),
                 span: GridSize(cols: 4, rows: 3),
                 component: .list(ListConfig(binding: topListBinding(),
                                             maxRows: 5,
                                             accent: .fromApp)))
        ]
    }

    // MARK: - Index rebuild

    private func rewriteIndex() throws {
        guard let dir = container.layoutsDirectoryURL(),
              let indexURL = container.layoutIndexURL() else {
            throw WidgetForgeError.containerUnavailable
        }
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordError: NSError?
        var inner: Error?
        coordinator.coordinate(writingItemAt: indexURL, options: .forReplacing, error: &coordError) { writeURL in
            do {
                let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
                var entries: [IndexEntry] = []
                for url in files where url.pathExtension == "json" && url.lastPathComponent != "index.json" {
                    guard let data = try? Data(contentsOf: url),
                          let layout = try? Self.decoder.decode(WidgetLayout.self, from: data) else { continue }
                    entries.append(IndexEntry(id: layout.id, name: layout.name,
                                              family: layout.family, updatedAt: layout.updatedAt))
                }
                let data = try Self.encoder.encode(entries)
                var opts: Data.WritingOptions = [.atomic]
                #if os(iOS) || os(tvOS) || os(watchOS)
                opts.insert(.completeFileProtectionUntilFirstUserAuthentication)
                #endif
                try data.write(to: writeURL, options: opts)
            } catch { inner = error }
        }
        if let coordError { throw WidgetForgeError.coordinationFailed(underlying: coordError) }
        if let inner { throw WidgetForgeError.coordinationFailed(underlying: inner) }
    }

    // MARK: - Coordinated write

    private static func coordinatedWrite(data: Data, to url: URL) throws {
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordError: NSError?
        var inner: Error?
        coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &coordError) { writeURL in
            do {
                var opts: Data.WritingOptions = [.atomic]
                #if os(iOS) || os(tvOS) || os(watchOS)
                opts.insert(.completeFileProtectionUntilFirstUserAuthentication)
                #endif
                try data.write(to: writeURL, options: opts)
            } catch { inner = error }
        }
        if let coordError { throw WidgetForgeError.coordinationFailed(underlying: coordError) }
        if let inner { throw WidgetForgeError.coordinationFailed(underlying: inner) }
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
