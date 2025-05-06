//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    public func pushUI() -> ActitoPushUI {
        ActitoPushUIImpl.instance
    }
}

extension Actito {
    internal func pushUIImplementation() -> ActitoPushUIImpl {
        ActitoPushUIImpl.instance
    }
}
