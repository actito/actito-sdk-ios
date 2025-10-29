//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension ActitoEventsModule {
    public func logNotificationReceived(_ id: String) async throws {
        let this = self as! ActitoInternalEventsModule
        try await this.log("re.notifica.event.notification.Receive", notificationId: id)
    }

    public func logNotificationInfluenced(_ id: String) async throws {
        let this = self as! ActitoInternalEventsModule
        try await this.log("re.notifica.event.notification.Influenced", notificationId: id)
    }

    public func logPushRegistration() async throws {
        let this = self as! ActitoInternalEventsModule
        try await this.log("re.notifica.event.push.Registration", notificationId: nil)
    }
}
