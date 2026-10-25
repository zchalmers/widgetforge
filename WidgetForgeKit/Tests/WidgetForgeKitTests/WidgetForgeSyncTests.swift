//
//  WidgetForgeSyncTests.swift
//  WidgetForgeKitTests
//

import XCTest
@testable import WidgetForgeKit

final class WidgetForgeSyncTests: XCTestCase {

    func test_runWithRetry_succeedsFirstTry_publishesOnce() async {
        let published = AtomicCounter()
        let ok = await WidgetForgeSyncTask.runWithRetry(
            identifier: "test.first", retryPolicy: .init(maxAttempts: 3, initialBackoff: 0),
            fetch: { "p" }, publish: { _ in published.increment() }, sleep: { _ in })
        XCTAssertTrue(ok); XCTAssertEqual(published.value, 1)
    }

    func test_runWithRetry_retriesTransientThenSucceeds() async {
        let attempts = AtomicCounter(); let published = AtomicCounter()
        let ok = await WidgetForgeSyncTask.runWithRetry(
            identifier: "test.transient", retryPolicy: .init(maxAttempts: 3, initialBackoff: 0),
            fetch: { if attempts.increment() < 2 { throw NSError(domain: "net", code: -1009) } ; return "p" },
            publish: { _ in published.increment() }, sleep: { _ in })
        XCTAssertTrue(ok); XCTAssertEqual(attempts.value, 2); XCTAssertEqual(published.value, 1)
    }

    func test_runWithRetry_exhaustsAndReturnsFailure() async {
        let attempts = AtomicCounter(); let published = AtomicCounter()
        let ok = await WidgetForgeSyncTask.runWithRetry(
            identifier: "test.exhaust", retryPolicy: .init(maxAttempts: 2, initialBackoff: 0),
            fetch: { attempts.increment(); throw NSError(domain: "net", code: -1009) },
            publish: { _ in published.increment() }, sleep: { _ in })
        XCTAssertFalse(ok); XCTAssertEqual(attempts.value, 2); XCTAssertEqual(published.value, 0)
    }

    func test_runWithRetry_oauthShortCircuits() async {
        let attempts = AtomicCounter()
        let ok = await WidgetForgeSyncTask.runWithRetry(
            identifier: "test.oauth", retryPolicy: .init(maxAttempts: 5, initialBackoff: 0),
            fetch: { attempts.increment(); throw WidgetForgeSyncError.oauthUnrecoverable },
            publish: { _ in }, sleep: { _ in })
        XCTAssertFalse(ok); XCTAssertEqual(attempts.value, 1)
    }

    func test_runWithRetry_publishFailureRetries() async {
        let published = AtomicCounter()
        let ok = await WidgetForgeSyncTask.runWithRetry(
            identifier: "test.pubfail", retryPolicy: .init(maxAttempts: 2, initialBackoff: 0),
            fetch: { "p" },
            publish: { _ in published.increment(); throw NSError(domain: "pub", code: 1) },
            sleep: { _ in })
        XCTAssertFalse(ok); XCTAssertEqual(published.value, 2)
    }
}

private final class AtomicCounter: @unchecked Sendable {
    private let lock = NSLock(); private var _v = 0
    var value: Int { lock.lock(); defer { lock.unlock() }; return _v }
    @discardableResult func increment() -> Int { lock.lock(); defer { lock.unlock() }; _v += 1; return _v }
}
