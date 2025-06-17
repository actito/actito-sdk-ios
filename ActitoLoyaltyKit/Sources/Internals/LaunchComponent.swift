//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

internal class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal let implementation = ActitoLoyaltyImpl.instance

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

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        switch command {
        case "canPresentPasses":
            return implementation.canPresentPasses

        case "present":
            guard
                let dict = data as? [String: Any],
                let controller = dict["controller"] as? UIViewController,
                let notification = dict["notification"] as? ActitoNotification
            else {
                throw ActitoError.invalidArgument(message: "Invalid data for present command")
            }

            await MainActor.run {
                implementation.present(notification: notification, in: controller)
            }
            return nil

        default:
            throw ActitoError.unsupportedCommand(message: "Unsupported command: \(command)")
        }
    }
}
