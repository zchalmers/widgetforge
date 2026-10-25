import XCTest
@testable import WidgetForgeKit

final class AppRegistryPlistDriftTests: XCTestCase {
    func testQuerySchemesMatchCheckedInFixture() throws {
        let url = Bundle.module.url(forResource: "expected-query-schemes",
                                    withExtension: "json",
                                    subdirectory: "Fixtures")
        XCTAssertNotNil(url, "Missing Fixtures/expected-query-schemes.json")
        let data = try Data(contentsOf: url!)
        let expected = try JSONDecoder().decode([String].self, from: data)
        XCTAssertEqual(AppRegistry.default.querySchemes, expected,
                       "AppRegistry.default.querySchemes drifted from checked-in fixture; regenerate the fixture and update the app target Info.plist Run Script phase.")
    }
}
