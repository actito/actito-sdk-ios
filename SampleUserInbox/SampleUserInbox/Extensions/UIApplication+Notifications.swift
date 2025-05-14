//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoPushUIKit
import Foundation
import UIKit

extension UIApplication {
    @MainActor
    internal var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            // .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter(\.isKeyWindow)
            .first
    }

    @MainActor
    internal var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }

    @MainActor
    internal func present(_ notification: ActitoNotification) {
        guard let rootViewController = rootViewController else {
            return
        }

        if !notification.requiresViewController {
            Actito.shared.pushUI().presentNotification(notification, in: rootViewController)
            return
        }

        let navigationController = UINavigationController()
        navigationController.view.backgroundColor = .systemBackground

        rootViewController.present(navigationController, animated: true) {
            Actito.shared.pushUI().presentNotification(notification, in: navigationController)
        }
    }

    @MainActor
    internal func present(_ action: ActitoNotification.Action, for notification: ActitoNotification) {
        guard let rootViewController = rootViewController else {
            return
        }

        Actito.shared.pushUI().presentAction(action, for: notification, in: rootViewController)
    }
}
