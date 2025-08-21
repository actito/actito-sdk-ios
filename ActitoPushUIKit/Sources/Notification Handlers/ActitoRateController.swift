//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import StoreKit
import UIKit

internal class ActitoRateController: ActitoNotificationPresenter {
    private let notification: ActitoNotification

    internal init(notification: ActitoNotification) {
        self.notification = notification
    }

    internal func present(in controller: UIViewController) {
        let alert = UIAlertController(title: notification.title ?? Bundle.main.applicationName,
                                      message: notification.message,
                                      preferredStyle: .alert)

        // Rate action
        alert.addAction(UIAlertAction(title: ActitoLocalizable.string(resource: .rateAlertYesButton), style: .default, handler: { _ in
            if #available(iOS 10.3, *), !LocalStorage.hasReviewedCurrentVersion {
                //                if #available(iOS 14.0, *), let scene = scene {
                //                    SKStoreReviewController.requestReview(in: scene)
                //                } else {
                SKStoreReviewController.requestReview()
                //                }

                LocalStorage.hasReviewedCurrentVersion = true
            } else {
                // Go to the Store instead
                if
                    let appStoreId = Actito.shared.application?.appStoreId,
                    let url = URL(string: "https://itunes.apple.com/app/id\(appStoreId)?action=write-review")
                {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    logger.warning("Cannot open the App Store.")
                }
            }

            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
        }))

        // Cancel action
        alert.addAction(
            UIAlertAction(title: ActitoLocalizable.string(resource: .rateAlertNoButton),
                          style: .default,
                          handler: { _ in
                              Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
                          })
        )

        controller.presentOrPush(alert) {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didPresentNotification: self.notification)
        }
    }
}
