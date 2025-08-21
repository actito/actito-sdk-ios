//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import UIKit

internal class ActitoAlertController: ActitoNotificationPresenter {
    private let notification: ActitoNotification

    internal init(notification: ActitoNotification) {
        self.notification = notification
    }

    internal func present(in controller: UIViewController) {
        let alert = UIAlertController(title: notification.title ?? Bundle.main.applicationName,
                                      message: notification.message,
                                      preferredStyle: .alert)

        notification.actions.forEach { action in
            alert.addAction(
                UIAlertAction(title: ActitoLocalizable.string(resource: action.label, fallback: action.label),
                              style: .default,
                              handler: { _ in
                                  Actito.shared.pushUI().presentAction(action, for: self.notification, in: controller)
                                  Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
                              })
            )
        }

        let useCancelButton = !notification.actions.isEmpty
        alert.addAction(UIAlertAction(title: ActitoLocalizable.string(resource: useCancelButton ? .cancelButton : .okButton),
                                      style: useCancelButton ? .cancel : .default,
                                      handler: { _ in
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
        }))

        controller.presentOrPush(alert) {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didPresentNotification: self.notification)
        }
    }
}
