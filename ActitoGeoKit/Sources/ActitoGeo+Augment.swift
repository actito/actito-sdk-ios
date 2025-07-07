//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    public func geo() -> ActitoGeo {
        ActitoGeoImpl.instance
    }
}

extension Actito {
    internal func geoImplementation() -> ActitoGeoImpl {
        ActitoGeoImpl.instance
    }
}
