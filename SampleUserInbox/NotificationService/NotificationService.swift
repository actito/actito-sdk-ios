//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoNotificationServiceExtensionKit
@preconcurrency import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @Sendable @escaping (UNNotificationContent) -> Void) {
        ActitoNotificationServiceExtension.handleNotificationRequest(request) { result in
            switch result {
            case let .success(content):
                contentHandler(content)

            case let .failure(error):
                print("Failed to handle the notification request.\n\(error)")
                contentHandler(request.content)
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    }
}
