//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

public class ActitoBaseActionHandler: NSObject {
    internal let notification: ActitoNotification
    internal let action: ActitoNotification.Action
    internal let sourceViewController: UIViewController

    internal init(notification: ActitoNotification, action: ActitoNotification.Action, sourceViewController: UIViewController) {
        self.notification = notification
        self.action = action
        self.sourceViewController = sourceViewController
    }

    internal func execute() {}

    internal func dismiss() {
        if let rootViewController = UIApplication.shared.rootViewController, rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true, completion: nil)
        } else {
            if sourceViewController is UIAlertController {
                UIApplication.shared.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                sourceViewController.dismiss(animated: true) {
                    self.sourceViewController.becomeFirstResponder()
                }
            }
        }
    }
}
