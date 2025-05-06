//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

public class ActitoCustomActionHandler: ActitoBaseActionHandler {
    internal override func execute() {
        if let target = action.target, let url = URL(string: target) {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didReceiveCustomAction: url, in: self.action, for: self.notification)
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
            }

            Task {
                try? await Actito.shared.createNotificationReply(notification: notification, action: action)
            }

            self.dismiss()
        } else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.invalidUrl)
            }
        }
    }
}

extension ActitoCustomActionHandler {
    public enum ActionError: LocalizedError {
        case invalidUrl

        public var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return "Invalid URL."
            }
        }
    }
}
