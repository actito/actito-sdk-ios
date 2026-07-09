//
// Copyright (c) 2026 Actito. All rights reserved.
//

import UserNotifications

public protocol ActitoNotificationCenter {
    func removeDeliveredNotifications(withIdentifiers: [String])

    func removeAllDeliveredNotifications()
}

extension UNUserNotificationCenter: ActitoNotificationCenter {}
