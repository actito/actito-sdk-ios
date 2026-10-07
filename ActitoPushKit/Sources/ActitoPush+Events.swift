//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension ActitoEventsComponent {
    public func logNotificationReceived(_ id: String, _ trackerId: String?) async throws {
        try await logInternalEvent(
            "re.notifica.event.notification.Receive",
            data: ["trackerId": trackerId],
            notificationId: id,
        )
    }

    public func logNotificationInfluenced(_ id: String, _ trackerId: String?) async throws {
        try await logInternalEvent(
            "re.notifica.event.notification.Influenced",
            data: ["trackerId": trackerId],
            notificationId: id,
        )
    }

    public func logPushRegistration() async throws {
        try await logInternalEvent("re.notifica.event.push.Registration", notificationId: nil)
    }
}
