## ReachabilityBridge

A simple wrapper under system's `Network->NWPathMonitor` framework which allows you to monitor reachability state in both Objective-C and Swift codebase.

### Usage

All you need to do is to create instance of ReachabilityBridge and start monitoring.

```swift
let bridge = ReachabilityBridge() 
bridge.startMonitoring()
```
After that you can simple check reachability status:

```swift
if bridge.isReachable {
    // TODO: retry network operation.
}
```

Check whether the device uses cellular data?

```swift
if bridge.isCellularBased {
    // TODO: show alert.
}

```

### How to listen for notifications?

You can use closure/delegate for both Objective-C and Swift  and Combine's Published for Swift.

-  Closure example:

```swift
let bridge = ReachabilityBridge()
// enable monitoring
bridge.startMonitoring()
// Use closure based notification
bridge.conNotification = { (isConnected) in
        //TODO: show no network connection banner if needed.
    }
```

- Combine example:

```swift
let bridge = ReachabilityBridge()
// enable monitoring
bridge.startMonitoring()
// Use Combine based notification
_ = bridge.$isReachable
    .sink { (_) in
    //TODO: show no network connection banner if needed.
    }
```

 -  Delegate example:
 
 ```swift
 
 class Foo: ReachabilityBridgeDelegate {
     let bridge: ReachabilityBridge
     init(bridge: ReachabilityBridge) {
         self.bridge = bridge
         // enable monitoring
         bridge.startMonitoring()
     }
     // Should be invoked on the main thread
     func didChanged(reachability: Bool) {
         //TODO: show no network connection banner if needed.
     }
 }
 
 let foo = Foo(bridge: ReachabilityBridge())
 // set Delegate
 foo.bridge.delegate = foo
 
 ```
