//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit

internal final class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false
    }

    internal func clearStorage() async throws {
        // no-op
    }

    internal func launch() async throws {
        // no-op
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
