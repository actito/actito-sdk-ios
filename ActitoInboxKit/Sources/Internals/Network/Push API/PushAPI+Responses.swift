//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit

extension ActitoInternals.PushAPI.Responses {
    internal struct RemoteInbox: Decodable {
        internal let inboxItems: [ActitoInternals.PushAPI.Models.RemoteInboxItem]
        internal let count: Int
        internal let unread: Int
    }
}
