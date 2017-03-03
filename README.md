## Swift-Daemon

You can daemonize any swift process.
`Daemon` can detach your swift script from shell.

```swift
import Foundation
import Daemon

DispatchQueue(label: "foo").async {
    while true {
        print(".")
        sleep(1)
    }
}

while true {
    sleep(1)
}

Daemon.daemonize()
```
