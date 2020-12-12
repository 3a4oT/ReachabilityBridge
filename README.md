## ReachabilityBridge [![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)

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

You can use closure/delegate for both Objective-C and Swift and Combine's Published for Swift.

- Closure example:

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

- Delegate example:

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
