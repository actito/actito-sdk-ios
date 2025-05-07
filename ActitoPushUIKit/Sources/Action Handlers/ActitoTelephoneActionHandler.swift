//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

public class ActitoTelephoneActionHandler: ActitoBaseActionHandler {
    internal override func execute() {
        if
            let target = action.target,
            let url = URL(string: target),
            UIApplication.shared.canOpenURL(url)
        {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    DispatchQueue.main.async {
                        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
                    }

                    Task {
                        try? await Actito.shared.createNotificationReply(notification: self.notification, action: self.action)
                    }

                    self.dismiss()
                }
            }
        } else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.notSupported)
            }
        }
    }
}

extension ActitoTelephoneActionHandler {
    public enum ActionError: LocalizedError {
        case notSupported

        public var errorDescription: String? {
            switch self {
            case .notSupported:
                return "The device does not support this action."
            }
        }
    }
}
