//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

internal struct LocalInboxItem: Sendable {
    internal let id: String
    internal var notification: ActitoNotification
    internal let time: Date
    internal var opened: Bool
    internal let visible: Bool
    internal let expires: Date?

    internal var isExpired: Bool {
        guard let expires else {
            return false
        }

        return expires <= Date()
    }
}
