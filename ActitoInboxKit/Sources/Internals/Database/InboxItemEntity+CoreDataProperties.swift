//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import CoreData

internal typealias InboxItemEntityCoreDataPropertiesSet = NSSet

extension InboxItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InboxItemEntity> {
        return NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
    }

    @NSManaged internal var expires: Date?
    @NSManaged internal var id: String?
    @NSManaged internal var notification: Data?
    @NSManaged internal var notificationId: String?
    @NSManaged internal var opened: Bool
    @NSManaged internal var time: Date?
    @NSManaged internal var visible: Bool

}

extension InboxItemEntity: Identifiable {}
