//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit

extension ActitoApplication {
    internal var hasInboxServiceEnabled: Bool {
        services[ActitoApplication.ServiceKey.inbox.rawValue] == true && inboxConfig?.useInbox == true
    }
}
