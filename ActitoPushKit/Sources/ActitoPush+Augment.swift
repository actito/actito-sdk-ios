//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    public func push() -> ActitoPush {
        ActitoPushImpl.instance
    }
}

extension Actito {
    internal func pushImplementation() -> ActitoPushImpl {
        ActitoPushImpl.instance
    }
}
