//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

internal class EventsLaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = EventsLaunchComponent()

    internal let implementation = ActitoEventsModuleImpl.instance

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to reachability changed events.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onReachabilityChanged(_:)),
            name: .reachabilityChanged,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        // no-op
    }

    internal func launch() async throws {
        implementation.processStoredEvents()
    }

    internal func postLaunch() async throws {
        // no-op
    }

    internal func unlaunch() async throws {
        // no-op
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}
