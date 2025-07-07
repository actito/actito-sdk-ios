//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    public func loyalty() -> ActitoLoyalty {
        ActitoLoyaltyImpl.instance
    }
}

extension Actito {
    internal func loyaltyImplementation() -> ActitoLoyaltyImpl {
        ActitoLoyaltyImpl.instance
    }
}
