//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import CoreData

internal struct LocalEvent: @unchecked Sendable {
    internal let objectID: NSManagedObjectID?
    internal let type: String
    internal let deviceId: String
    internal let sessionId: String?
    internal let notificationId: String?
    internal let userId: String?
    internal let data: ActitoAnyCodable?
    internal let timestamp: Int64
    internal let ttl: Int32
    internal var retries: Int16
}
