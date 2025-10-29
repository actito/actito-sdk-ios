//
// Copyright (c) 2025 Actito. All rights reserved.
//

import CoreLocation
import Foundation

extension ActitoBeacon.Proximity {
    internal init?(_ clp: CLProximity) {
        switch clp {
        case .unknown:
            return nil
        case .immediate:
            self = .immediate
        case .near:
            self = .near
        case .far:
            self = .far
        @unknown default:
            return nil
        }
    }
}
