//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    public func scannables() -> ActitoScannables {
        ActitoScannablesImpl.instance
    }
}

extension Actito {
    internal func scannablesImplementation() -> ActitoScannablesImpl {
        ActitoScannablesImpl.instance
    }
}
