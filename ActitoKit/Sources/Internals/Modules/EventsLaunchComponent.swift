//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

internal final class EventsLaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = EventsLaunchComponent()

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            Actito.shared.eventsImplementation(),
            selector: #selector(Actito.shared.eventsImplementation().onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to reachability changed events.
        NotificationCenter.default.upsertObserver(
            Actito.shared.eventsImplementation(),
            selector: #selector(Actito.shared.eventsImplementation().onReachabilityChanged(_:)),
            name: .reachabilityChanged,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        // no-op
    }

    internal func launch() async throws {
        Actito.shared.eventsImplementation().processStoredEvents()
    }

    internal func postLaunch() async throws {
        // no-op
    }

    internal func unlaunch() async throws {
        // no-op
    }

    internal func executeCommand(_ command: String, data: Any?) throws -> (any Sendable)? {
        return nil
    }
}
