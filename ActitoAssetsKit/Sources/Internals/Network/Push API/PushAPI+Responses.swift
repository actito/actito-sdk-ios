//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit

extension ActitoInternals.PushAPI.Responses {
    internal struct Assets: Decodable, Sendable {
        internal let assets: [ActitoInternals.PushAPI.Models.Asset]
    }
}
