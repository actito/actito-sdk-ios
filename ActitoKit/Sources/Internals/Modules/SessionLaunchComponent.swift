//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

internal class SessionLaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = SessionLaunchComponent()

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        // Listen to 'application did become active'
        NotificationCenter.default.upsertObserver(
            Actito.shared.session(),
            selector: #selector(Actito.shared.session().applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to 'application will resign active'
        NotificationCenter.default.upsertObserver(
            Actito.shared.session(),
            selector: #selector(Actito.shared.session().applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        // no-op
    }

    internal func launch() async throws {
        if
            Actito.shared.session().sessionId == nil,
            Actito.shared.device().currentDevice != nil,
            await UIApplication.shared.applicationState == .active
        {
            // Launch is taking place after the application came to the foreground.
            // Start the application session.
            await Actito.shared.session().startSession()
        }
    }

    internal func postLaunch() async throws {
        // no-op
    }

    internal func unlaunch() async throws {
        Actito.shared.session().sessionEnd = Date()
        await Actito.shared.session().stopSession()
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}
