//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension ActitoInternals.PushAPI.Responses {
    internal struct UserInboxNotification: Decodable {
        internal let notification: ActitoInternals.PushAPI.Models.Notification
    }
}
