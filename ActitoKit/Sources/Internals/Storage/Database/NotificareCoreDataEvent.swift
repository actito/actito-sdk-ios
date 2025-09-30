//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import CoreData

@objc(NotificareCoreDataEvent)
internal class NotificareCoreDataEvent: NSManagedObject, Identifiable {
    @NSManaged internal var data: Data?
    @NSManaged internal var deviceId: String?
    @NSManaged internal var notificationId: String?
    @NSManaged internal var retries: Int16
    @NSManaged internal var sessionId: String?
    @NSManaged internal var timestamp: Int64
    @NSManaged internal var ttl: Int32
    @NSManaged internal var type: String?
    @NSManaged internal var userId: String?
}
