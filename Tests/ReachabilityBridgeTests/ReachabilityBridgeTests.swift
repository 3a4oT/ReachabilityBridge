import XCTest
@testable import ReachabilityBridge

final class ReachabilityBridgeTests: XCTestCase {
    func testReachabilityBridgeLiveCycle() {
        let bridge = ReachabilityBridge()
        // Default state
        XCTAssertFalse(bridge.isMonitoring)
        XCTAssertFalse(bridge.isReachable)
        XCTAssertFalse(bridge.isCellularBased)
        XCTAssertNil(bridge.conNotification)
        XCTAssertNil(bridge.delegate)
        // Change state after start
        bridge.startMonitoring()
        let exp = XCTestExpectation()
        bridge.conNotification = {(_) in
            exp.fulfill()
        }
        self.wait(for: [exp], timeout: 2.0)
        XCTAssertTrue(bridge.isMonitoring)
        XCTAssertTrue(bridge.isReachable)
        XCTAssertFalse(bridge.isCellularBased)
        // Change state after stop
        bridge.stopMonitoring()
        XCTAssertFalse(bridge.isMonitoring)
        XCTAssertFalse(bridge.isReachable)
        XCTAssertFalse(bridge.isCellularBased)
    }
    func testSharedIsReachable() {
        let expectation = XCTestExpectation(description: "wait until reachability status changed")
        let sharedBridge = ReachabilityBridge.shared
        sharedBridge.startMonitoring()
        let sig = sharedBridge.$isReachable
            .sink {[weak expectation] (_) in
                expectation?.fulfill()
            }
        self.wait(for: [expectation], timeout: 3.0)
        XCTAssertTrue(sharedBridge.isReachable)
        XCTAssertTrue(sharedBridge.isMonitoring)
        sig.cancel()
        sharedBridge.stopMonitoring()
        XCTAssertFalse(sharedBridge.isMonitoring)
    }
    func testReachabilityNotifiers() {
        class Foo: ReachabilityBridgeDelegate {
            private (set) var bar = false
            let bridge: ReachabilityBridge
            init(bridge: ReachabilityBridge) {
                self.bridge = bridge
                bridge.startMonitoring()
            }
            func didChanged(reachability: Bool) {
                XCTAssertTrue(Thread.isMainThread, "Should be invoked on the main thread")
                self.bar = reachability
            }
        }
        // Create an expectation for a notifier
        let expectation = XCTestExpectation(description: "wait until reachability status changed")
        // set up test env
        let foo = Foo(bridge: ReachabilityBridge())
        XCTAssertFalse(foo.bar, "Should be - false as default value")
        // Connect Delegate based notifier
        foo.bridge.delegate = foo
        // Connect block based notifier
        foo.bridge.conNotification = { (isConnected) in
            XCTAssertTrue(Thread.isMainThread, "Should be invoked on the main thread")
            // Test delegate
            XCTAssertTrue(foo.bar, "Should be set by a delegate")
            // Test closure
            XCTAssertTrue(isConnected)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 3.0)
        foo.bridge.stopMonitoring()
        XCTAssertFalse(foo.bridge.isMonitoring)
    }
}
