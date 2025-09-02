//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import CoreData
import Foundation

extension ActitoInternals.PushAPI.Payloads.CreateEventPayload {
    internal init(from local: LocalEvent) {
        self.init(
            type: local.type,
            timestamp: local.timestamp,
            deviceId: local.deviceId,
            sessionId: local.sessionId,
            notificationId: local.notificationId,
            userId: local.userId,
            data: local.data?.value as? ActitoEventData
        )
    }

    internal func toLocal() -> LocalEvent {
        LocalEvent(
            objectID: nil,
            type: type,
            deviceId: deviceId,
            sessionId: sessionId,
            notificationId: notificationId,
            userId: userId,
            data: ActitoAnyCodable(data),
            timestamp: timestamp,
            ttl: 24 * 60 * 60, // 24 hours in seconds
            retries: 0
        )
    }
}
