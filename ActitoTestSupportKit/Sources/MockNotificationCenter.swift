//
// Copyright (c) 2026 . All rights reserved.
//

import ActitoUtilitiesKit

public class MockNotificationCenter: ActitoNotificationCenter {
    public init() {}

    public func removeDeliveredNotifications(withIdentifiers: [String]) {
        // no-op
    }

    public func removeAllDeliveredNotifications() {
        // no-op
    }
}
