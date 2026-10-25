#if canImport(SwiftUI)
import XCTest
@testable import WidgetForgeKit

/// Guards the generated persona-tailored default catalog: every layout must
/// pass the real LayoutValidator, carry a unique stable id, and bind only to
/// slices that exist in KnownSliceCatalog with a matching component/slice kind.
final class DefaultLayoutCatalogTests: XCTestCase {
    func testCatalogIsNonTrivial() {
        let all = DefaultLayoutCatalog.all()
        XCTAssertGreaterThanOrEqual(all.count, 15, "Expected a rich default catalog")
        // At least 2 layouts per family.
        for family in LayoutFamily.allCases {
            let n = all.filter { $0.family == family }.count
            XCTAssertGreaterThanOrEqual(n, 2, "Family \(family) should have >= 2 defaults, has \(n)")
        }
    }

    func testEveryLayoutValidatesAgainstItsGrid() throws {
        for layout in DefaultLayoutCatalog.all() {
            XCTAssertNoThrow(try LayoutValidator.validate(layout),
                             "Layout '\(layout.name)' (\(layout.family)) failed grid validation")
        }
    }

    func testStableIdsAreUniqueAndDeterministic() {
        let a = DefaultLayoutCatalog.all()
        let b = DefaultLayoutCatalog.all()
        // Deterministic: same ids across calls (idempotent seeding depends on this).
        XCTAssertEqual(a.map(\.id), b.map(\.id))
        // Unique: no two layouts share an id.
        XCTAssertEqual(Set(a.map(\.id)).count, a.count, "Duplicate layout ids in catalog")
    }

    func testEveryBindingResolvesToAKnownSliceOfMatchingKind() {
        for layout in DefaultLayoutCatalog.all() {
            for cell in layout.cells {
                guard let (binding, requiredKind) = bindingAndKind(cell.component) else { continue }
                let known = KnownSliceCatalog.slices(for: binding.bundleId)
                guard let slice = known.first(where: { $0.sliceId == binding.sliceId }) else {
                    XCTFail("Layout '\(layout.name)': binding \(binding.bundleId)/\(binding.sliceId) not in KnownSliceCatalog")
                    continue
                }
                XCTAssertEqual(slice.kind, requiredKind,
                               "Layout '\(layout.name)': slice \(binding.sliceId) is \(slice.kind), component needs \(requiredKind)")
            }
        }
    }

    /// Returns the data binding + the slice kind the component requires, or nil
    /// for non-data components (header/appTile).
    private func bindingAndKind(_ component: Component) -> (DataBinding, SliceKind)? {
        switch component {
        case .count(let c): return (c.binding, .count)
        case .list(let c): return (c.binding, .list)
        case .metric(let c): return (c.binding, .metric)
        case .status(let c): return (c.binding, .status)
        case .progress(let c): return (c.binding, .progress)
        case .header, .appTile: return nil
        }
    }
}
#endif
