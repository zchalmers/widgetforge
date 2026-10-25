import XCTest
@testable import WidgetForgeKit

final class LayoutStoreTests: XCTestCase {
    private func makeContainer() throws -> SharedContainer {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        return SharedContainer(overrideURL: tmp)
    }

    private func makeLayout(family: LayoutFamily = .medium, name: String = "L") -> WidgetLayout {
        WidgetLayout(name: name, family: family,
                     cells: [Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 1),
                                  component: .header(.init(title: "H", subtitle: nil, accent: .fromApp)))],
                     background: .system,
                     createdAt: Date(timeIntervalSince1970: 1),
                     updatedAt: Date(timeIntervalSince1970: 2))
    }

    func testRoundTrip() throws {
        let s = LayoutStore(container: try makeContainer())
        let l = makeLayout()
        try s.write(l)
        XCTAssertEqual(try s.read(id: l.id), l)
    }

    func testIndexReflectsWrites() throws {
        let s = LayoutStore(container: try makeContainer())
        let l1 = makeLayout(name: "A"), l2 = makeLayout(family: .large, name: "B")
        try s.write(l1); try s.write(l2)
        let ids = s.readIndex().map(\.id).sorted { $0.uuidString < $1.uuidString }
        XCTAssertEqual(ids, [l1.id, l2.id].sorted { $0.uuidString < $1.uuidString })
    }

    func testDeleteRemovesLayoutAndIndex() throws {
        let s = LayoutStore(container: try makeContainer())
        let l = makeLayout()
        try s.write(l)
        try s.delete(id: l.id)
        XCTAssertTrue(s.readIndex().isEmpty)
        XCTAssertThrowsError(try s.read(id: l.id))
    }

    func testWriteRejectsOverlapping() throws {
        let s = LayoutStore(container: try makeContainer())
        let bad = WidgetLayout(
            name: "bad", family: .large,
            cells: [
                Cell(origin: GridPoint(col: 0, row: 0), span: GridSize(cols: 2, rows: 2),
                     component: .header(.init(title: "A", subtitle: nil, accent: .fromApp))),
                Cell(origin: GridPoint(col: 1, row: 1), span: GridSize(cols: 2, rows: 2),
                     component: .header(.init(title: "B", subtitle: nil, accent: .fromApp)))
            ],
            background: .system
        )
        XCTAssertThrowsError(try s.write(bad))
    }

    func testConcurrentWritesAcrossIds() throws {
        let s = LayoutStore(container: try makeContainer())
        let queue = DispatchQueue(label: "t", attributes: .concurrent)
        let group = DispatchGroup()
        for _ in 0..<10 {
            group.enter()
            queue.async {
                let l = self.makeLayout(name: UUID().uuidString)
                _ = try? s.write(l)
                group.leave()
            }
        }
        group.wait()
        XCTAssertEqual(s.readIndex().count, 10)
    }

    func testDefaultLayoutForEachFamily() {
        for family in LayoutFamily.allCases {
            let l = LayoutStore.defaultLayout(for: family)
            XCTAssertEqual(l.family, family)
            XCTAssertNoThrow(try LayoutValidator.validate(l))
        }
    }

    func testDefaultLayoutIsRichAndBoundToInbox() {
        let knownSliceIds: Set<String> = ["pendingCount", "topApprovals", "approvalStatus"]
        for family in LayoutFamily.allCases {
            let l = LayoutStore.defaultLayout(for: family)
            XCTAssertGreaterThanOrEqual(l.cells.count, 2, "family \(family) default should have header + at least one bound cell")

            // First cell must be a WidgetForge-titled header without the old "Not activated yet" copy.
            guard case .header(let header) = l.cells.first?.component else {
                return XCTFail("family \(family) first cell should be a header")
            }
            XCTAssertEqual(header.title, "WidgetForge")
            XCTAssertNotEqual(header.subtitle, "Not activated yet")

            // At least one cell must be bound to Inbox with a known slice id.
            let boundBundleIds: [String] = l.cells.compactMap { cell -> String? in
                switch cell.component {
                case .count(let c) where knownSliceIds.contains(c.binding.sliceId): return c.binding.bundleId
                case .list(let c) where knownSliceIds.contains(c.binding.sliceId): return c.binding.bundleId
                case .status(let c) where knownSliceIds.contains(c.binding.sliceId): return c.binding.bundleId
                case .metric(let c) where knownSliceIds.contains(c.binding.sliceId): return c.binding.bundleId
                case .progress(let c) where knownSliceIds.contains(c.binding.sliceId): return c.binding.bundleId
                default: return nil
                }
            }
            XCTAssertTrue(boundBundleIds.contains("com.example.it.inbox"),
                          "family \(family) default should include at least one Inbox-bound cell (got \(boundBundleIds))")
        }
    }
}
