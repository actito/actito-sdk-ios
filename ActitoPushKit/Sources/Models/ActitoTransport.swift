//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

/// Identifies the transport mechanism used to deliver a notification.
///
/// This value indicates the underlying push delivery service used by Actito,
/// such as APNS for iOS or GCM for Android.
public enum ActitoTransport: String, Codable, Sendable {
    /// Indicates a temporarily registered device without remote notifications enabled,
    /// before a push transport (APNS) is available.
    case notificare = "Notificare"

    /// Apple Push Notification Service
    case apns = "APNS"
}
