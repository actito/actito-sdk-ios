//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import CoreData

@objc(InboxItemEntity)
internal class InboxItemEntity: NSManagedObject, Identifiable {
    @NSManaged internal var expires: Date?
    @NSManaged internal var id: String?
    @NSManaged internal var notification: Data?
    @NSManaged internal var notificationId: String?
    @NSManaged internal var opened: Bool
    @NSManaged internal var time: Date?
    @NSManaged internal var visible: Bool
}
