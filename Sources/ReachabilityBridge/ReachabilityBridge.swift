import Foundation
import Network

/// Reachability state changes
@objc public protocol ReachabilityBridgeDelegate: class {
    /// Will be triggered in the main thread.
    func didChanged(reachability: Bool)
}
/// Reachability monitor which can be used for both Objective-C and Swift codebase.
/// You can use Combine, closure or delegate based notification handling method.
/// It's based on the system's Network framework.
@objc public final class ReachabilityBridge: NSObject {
    /// delegate which will be invoked in the main thread when reachability state was changed
    @objc public weak var delegate: ReachabilityBridgeDelegate?
    /// singleton instance. Should be used DI pattern where possible (just create the ReachabilityBridge() instance and pass as a dependency)
    /// But Hey! If you want it - hold it :)
    @objc public static let shared: ReachabilityBridge = ReachabilityBridge()
    private let monitorQueue: DispatchQueue = DispatchQueue(label: "ReachabilityBridge.Monitor.Q")
    private let monitor = NWPathMonitor()
    /// shows whether reachability monitor is working
    @objc public private(set) var isMonitoring: Bool = false
    /// shows whether device is reachable
    @Published
    @objc public private(set) var isReachable: Bool = false
    /// Cellular interface or WiFi hotspots from an iOS device.
    @Published
    @objc public private(set) var isCellularBased: Bool = false
    @Published
    @objc public var isConstrained: Bool = false
    /// closure which will be invoked in the main thread when reachability state was changed
    @objc public var conNotification: ((_ isConnected: Bool) -> ())?
    public override init() {
        super.init()
    }
    /// enable reachability monitoring/notifications.
    @objc public func startMonitoring() {
        guard !self.isMonitoring else {
            return
        }
        self.monitor.start(queue: self.monitorQueue)
        self.isMonitoring = true
        self.monitor.pathUpdateHandler = {[weak self] path in
            let satisfied = (path.status == .satisfied) ? true : false
            // Notify only when state changed
            if satisfied != self?.isReachable {
                DispatchQueue.main.async {
                    // notify #1
                    self?.delegate?.didChanged(reachability: satisfied)
                    // notify #2
                    if let notifier = self?.conNotification {
                        notifier(satisfied)
                    }
                }
            }
            self?.isConstrained = path.isConstrained
            self?.isCellularBased = path.isExpensive
            // set current state
            self?.isReachable = satisfied
        }
    }
    /// finish reachability monitoring and reset all flags to the default state.
    @objc public func stopMonitoring() {
        self.isReachable = false
        self.isConstrained = false
        self.isCellularBased = false
        self.isMonitoring = false
        self.monitor.cancel()
    }
    deinit {
        self.stopMonitoring()
    }
}
