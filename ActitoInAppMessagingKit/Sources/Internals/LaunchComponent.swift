//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

internal class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false

        // Listen to when the application comes into the foreground.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inAppMessagingImplementation(),
            selector: #selector(Actito.shared.inAppMessagingImplementation().onApplicationForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to when the application goes into the background.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inAppMessagingImplementation(),
            selector: #selector(Actito.shared.inAppMessagingImplementation().onApplicationBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        // no-op
    }

    internal func launch() async throws {
        Actito.shared.inAppMessagingImplementation().evaluateContext(.launch)
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
