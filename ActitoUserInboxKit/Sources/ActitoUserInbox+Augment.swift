//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    public func userInbox() -> ActitoUserInbox {
        ActitoUserInboxImpl.instance
    }
}

extension Actito {
    internal func userInboxImplementation() -> ActitoUserInboxImpl {
        ActitoUserInboxImpl.instance
    }
}
