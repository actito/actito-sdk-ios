//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

internal struct ConsumerUserInboxResponse: Codable, Equatable {
    internal let count: Int
    internal let unread: Int
    internal let items: [ActitoUserInboxItem]
}
