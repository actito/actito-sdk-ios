//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension Notification.Name {
    // Core
    internal static let actitoStatus = Notification.Name(rawValue: "app.actito_launched")

    // Push
    internal static let notificationSettingsChanged = Notification.Name(rawValue: "app.notification_settings_changed")
    internal static let notifyInboxUpdate = Notification.Name(rawValue: "app.notification_inbox_update")
}
