//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

@MainActor
public protocol ActitoInboxDelegate: AnyObject {
    /// Called when the inbox is successfully updated.
    ///
    /// - Parameters:
    ///   - actitoInbox: The ActitoInbox object instance.
    ///   - items: The updated list of ``ActitoInboxItem``
    func actito(_ actitoInbox: ActitoInbox, didUpdateInbox items: [ActitoInboxItem])

    /// Called when the unread message count badge is updated.
    ///
    /// - Parameters:
    ///   - actitoInbox: The ActitoInbox object instance.
    ///   - badge: The updated unread messages count.
    func actito(_ actitoInbox: ActitoInbox, didUpdateBadge badge: Int)
}

extension ActitoInboxDelegate {
    public func actito(_: ActitoInbox, didUpdateInbox _: [ActitoInboxItem]) {}

    public func actito(_: ActitoInbox, didUpdateBadge _: Int) {}
}
