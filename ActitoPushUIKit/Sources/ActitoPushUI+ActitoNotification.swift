//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit

extension ActitoNotification {
    public var requiresViewController: Bool {
        guard let type = ActitoNotification.NotificationType(rawValue: type) else {
            return true
        }

        switch type {
        case .none, .passbook, .alert, .rate, .store, .urlScheme, .inAppBrowser:
            return false

        case .urlResolver:
            let result = NotificationUrlResolver.resolve(self)

            switch result {
            case .none, .urlScheme, .inAppBrowser:
                return false
            case .webView:
                return true
            }

        default:
            return true
        }
    }
}
