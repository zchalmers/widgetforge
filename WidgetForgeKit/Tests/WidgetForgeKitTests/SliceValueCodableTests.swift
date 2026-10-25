import XCTest
@testable import WidgetForgeKit

final class SliceValueCodableTests: XCTestCase {
    private let enc: JSONEncoder = { let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; e.outputFormatting = [.sortedKeys]; return e }()
    private let dec: JSONDecoder = { let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d }()

    func testCountRoundTrip() throws {
        let v = SliceValue.count(7)
        let data = try enc.encode(v)
        let str = String(data: data, encoding: .utf8)!
        XCTAssertTrue(str.contains("\"type\":\"count\""))
        XCTAssertTrue(str.contains("\"payload\":7"))
        XCTAssertEqual(try dec.decode(SliceValue.self, from: data), v)
    }

    func testListRoundTrip() throws {
        let ts = Date(timeIntervalSince1970: 1_700_000_000)
        let v = SliceValue.list([
            .init(id: "a", title: "Alpha", subtitle: "Sub", timestamp: ts, deepLink: URL(string: "widget://a"))
        ])
        let data = try enc.encode(v)
        XCTAssertEqual(try dec.decode(SliceValue.self, from: data), v)
    }

    func testMetricRoundTrip() throws {
        let v = SliceValue.metric(42.5, unit: "USD", trend: .up)
        XCTAssertEqual(try dec.decode(SliceValue.self, from: try enc.encode(v)), v)
    }

    func testStatusRoundTrip() throws {
        let v = SliceValue.status(.warning, text: "Latency spike")
        XCTAssertEqual(try dec.decode(SliceValue.self, from: try enc.encode(v)), v)
    }

    func testProgressRoundTrip() throws {
        let v = SliceValue.progress(0.6, label: "Q3 quota")
        XCTAssertEqual(try dec.decode(SliceValue.self, from: try enc.encode(v)), v)
    }

    func testUnknownDiscriminatorThrows() {
        let json = #"{"type":"bogus","payload":{}}"#.data(using: .utf8)!
        XCTAssertThrowsError(try dec.decode(SliceValue.self, from: json)) { error in
            guard case WFDecodeError.unknownDiscriminator(let s) = error else {
                return XCTFail("wrong error: \(error)")
            }
            XCTAssertEqual(s, "bogus")
        }
    }

    func testKindMapping() {
        XCTAssertEqual(SliceValue.count(0).kind, .count)
        XCTAssertEqual(SliceValue.list([]).kind, .list)
        XCTAssertEqual(SliceValue.metric(0, unit: nil, trend: nil).kind, .metric)
        XCTAssertEqual(SliceValue.status(.ok, text: "").kind, .status)
        XCTAssertEqual(SliceValue.progress(0, label: "").kind, .progress)
    }
}
