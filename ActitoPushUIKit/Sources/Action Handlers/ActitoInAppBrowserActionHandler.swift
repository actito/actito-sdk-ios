//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import SafariServices
import UIKit

public class ActitoInAppBrowserActionHandler: ActitoBaseActionHandler {
    internal override func execute() {
        if let target = action.target,
           let url = URL(string: target),
           url.isHttpUrl
        {
            DispatchQueue.main.async {
                let theme = Actito.shared.options?.theme(for: self.sourceViewController)
                let safariViewController = Actito.shared.pushUI().createSafariViewController(url: url, theme: theme)
                safariViewController.delegate = self

                self.sourceViewController.presentOrPush(safariViewController)
            }
        } else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.invalidUrl)
            }
        }
    }
}

extension ActitoInAppBrowserActionHandler: SFSafariViewControllerDelegate {
    public func safariViewController(_: SFSafariViewController, didCompleteInitialLoad successfully: Bool) {
        if successfully {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
            }

            Task {
                try? await Actito.shared.createNotificationReply(notification: notification, action: action)
            }
        } else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: nil)
            }
        }
    }

    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss()
    }
}

extension ActitoInAppBrowserActionHandler {
    public enum ActionError: LocalizedError {
        case invalidUrl

        public var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return "The target of the action is not a valid URL."
            }
        }
    }
}
