//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension ActitoInternals.PushAPI.Responses {
    internal struct InAppMessage: Decodable {
        internal let message: ActitoInternals.PushAPI.Models.Message
    }
}
