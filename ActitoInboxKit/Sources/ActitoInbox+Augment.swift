//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    public func inbox() -> ActitoInbox {
        ActitoInboxImpl.instance
    }
}

extension Actito {
    internal func inboxImplementation() -> ActitoInboxImpl {
        ActitoInboxImpl.instance
    }
}
