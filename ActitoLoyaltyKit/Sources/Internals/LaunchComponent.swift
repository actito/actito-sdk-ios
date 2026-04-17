//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

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
        switch command {
        case "canPresentPasses":
            return Actito.shared.loyalty().canPresentPasses

        case "presentPass":
            guard
                let dict = data as? [String: Any],
                let controller = dict["controller"] as? UIViewController,
                let notification = dict["notification"] as? ActitoNotification
            else {
                throw ActitoError.invalidArgument(message: "Invalid data for present passbook command")
            }

            guard let type = ActitoNotification.NotificationType(rawValue: notification.type) else {
                throw ActitoError.invalidArgument(message: "Unhandled notification type '\(notification.type)'.")
            }

            switch type {
            case .passbook:
                Actito.shared.loyalty().presentPassbook(notification: notification, in: controller)
                return nil

            case .pass:
                Actito.shared.loyalty().presentPass(notification: notification, in: controller)
                return nil

            default:
                throw ActitoError.invalidArgument(message: "Wrong type for pass presentation: \(type)")
            }

        default:
            throw ActitoError.unsupportedCommand(message: "Unsupported command: \(command)")
        }
    }
}
