//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

/// Indicates the delivery mechanism of a notification.
///
/// This enum is used to describe how a notification was delivered
/// to the device.
public enum ActitoNotificationDeliveryMechanism: String, Codable, Sendable {
    /// Standard delivery: the notification is displayed normally to the user,
    /// with alerts, sounds, or badges as configured.
    case standard

    /// Silent delivery: the notification is delivered silently without
    /// alerting the user.
    case silent
}
