//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension ActitoInboxItem {
    internal var isExpired: Bool {
        if let expiresAt = expires {
            return expiresAt <= Date()
        }

        return false
    }
}
