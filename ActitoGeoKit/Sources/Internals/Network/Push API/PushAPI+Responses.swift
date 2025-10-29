//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension ActitoInternals.PushAPI.Responses {
    internal struct FetchRegions: Decodable {
        internal let regions: [ActitoInternals.PushAPI.Models.Region]
    }

    internal struct FetchBeacons: Decodable {
        internal let beacons: [ActitoInternals.PushAPI.Models.Beacon]
    }
}
