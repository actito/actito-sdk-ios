//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit

extension ActitoInternals.PushAPI.Payloads {
    internal struct UpdateDeviceSubscription: Encodable {
        internal let transport: ActitoTransport
        internal let subscriptionId: String?
        internal let allowedUI: Bool
    }

    internal struct UpdateDeviceNotificationSettings: Encodable {
        internal let allowedUI: Bool
    }

    internal struct RegisterLiveActivity: Encodable {
        internal let activity: String
        internal let token: String
        internal let deviceID: String
        internal let topics: [String]?
    }
}
