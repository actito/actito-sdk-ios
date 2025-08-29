//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import UIKit

public class ActitoBrowserActionHandler: ActitoBaseActionHandler {
    internal override func execute() {
        if
            let target = action.target,
            let url = URL(string: target),
            let urlScheme = url.scheme,
            Bundle.main.getSupportedUrlSchemes().contains(urlScheme) || UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:]) { _ in
                DispatchQueue.main.async {
                    Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
                }

                Task {
                    try? await Actito.shared.createNotificationReply(notification: self.notification, action: self.action)
                }

                self.dismiss()
            }
        } else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.invalidUrl)
            }
        }
    }
}

extension ActitoBrowserActionHandler {
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
