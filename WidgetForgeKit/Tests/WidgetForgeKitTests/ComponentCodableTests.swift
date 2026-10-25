import XCTest
@testable import WidgetForgeKit

final class ComponentCodableTests: XCTestCase {
    private let enc: JSONEncoder = { let e = JSONEncoder(); e.outputFormatting = [.sortedKeys]; return e }()
    private let dec = JSONDecoder()

    private let sampleBinding = DataBinding(bundleId: "com.example.Dashboard", sliceId: "s1")

    func testAllCasesRoundTrip() throws {
        let cases: [Component] = [
            .count(.init(binding: sampleBinding, caption: "Pending", accent: .fromApp)),
            .list(.init(binding: sampleBinding, maxRows: 5, accent: .token(.teal))),
            .metric(.init(binding: sampleBinding, caption: "Revenue", accent: .token(.amber))),
            .status(.init(binding: sampleBinding, accent: .fromApp)),
            .progress(.init(binding: sampleBinding, style: .ring, accent: .token(.violet))),
            .header(.init(title: "Sales", subtitle: "Q3", accent: .fromApp)),
            .appTile(.init(bundleId: "com.example.Dashboard", accent: .fromApp))
        ]
        for c in cases {
            let data = try enc.encode(c)
            XCTAssertEqual(try dec.decode(Component.self, from: data), c)
        }
    }

    func testDiscriminatorPresent() throws {
        let c = Component.count(.init(binding: sampleBinding, caption: nil, accent: .fromApp))
        let str = String(data: try enc.encode(c), encoding: .utf8)!
        XCTAssertTrue(str.contains("\"type\":\"count\""))
    }

    func testUnknownDiscriminatorThrows() {
        let json = #"{"type":"bogus","payload":{}}"#.data(using: .utf8)!
        XCTAssertThrowsError(try dec.decode(Component.self, from: json)) { error in
            guard case WFDecodeError.unknownDiscriminator(let s) = error else {
                return XCTFail("wrong: \(error)")
            }
            XCTAssertEqual(s, "bogus")
        }
    }

    func testRequiredSliceKind() {
        XCTAssertEqual(Component.count(.init(binding: sampleBinding, caption: nil, accent: .fromApp)).requiredSliceKind, .count)
        XCTAssertEqual(Component.list(.init(binding: sampleBinding, maxRows: 1, accent: .fromApp)).requiredSliceKind, .list)
        XCTAssertEqual(Component.metric(.init(binding: sampleBinding, caption: nil, accent: .fromApp)).requiredSliceKind, .metric)
        XCTAssertEqual(Component.status(.init(binding: sampleBinding, accent: .fromApp)).requiredSliceKind, .status)
        XCTAssertEqual(Component.progress(.init(binding: sampleBinding, style: .bar, accent: .fromApp)).requiredSliceKind, .progress)
        XCTAssertNil(Component.header(.init(title: "H", subtitle: nil, accent: .fromApp)).requiredSliceKind)
        XCTAssertNil(Component.appTile(.init(bundleId: "x", accent: .fromApp)).requiredSliceKind)
    }
}
