//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import SafariServices
import UIKit

internal class ActitoInAppBrowserController: NSObject, ActitoNotificationPresenter {
    private let notification: ActitoNotification

    internal init(notification: ActitoNotification) {
        self.notification = notification
    }

    internal func present(in controller: UIViewController) {
        guard let content = notification.content.first,
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)?.removingQueryComponent(name: "notificareWebView"),
              url.isHttpUrl
        else {
            Task { @MainActor in
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        let theme = Actito.shared.options?.theme(for: controller)
        let safariViewController = Actito.shared.pushUI().createSafariViewController(url: url, theme: theme)
        safariViewController.delegate = self

        controller.presentOrPush(safariViewController)
    }
}

extension ActitoInAppBrowserController: SFSafariViewControllerDelegate {
    public func safariViewController(_: SFSafariViewController, didCompleteInitialLoad successfully: Bool) {
        Task { @MainActor in
            if successfully {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didPresentNotification: self.notification)
            } else {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }
        }
    }

    public func safariViewControllerDidFinish(_: SFSafariViewController) {
        Task { @MainActor in
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
        }
    }
}
