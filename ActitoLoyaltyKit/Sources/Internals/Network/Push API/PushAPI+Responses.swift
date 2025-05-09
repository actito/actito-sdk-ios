//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension ActitoInternals.PushAPI.Responses {
    internal struct Pass: Decodable {
        internal let pass: ActitoInternals.PushAPI.Models.Pass
    }

    internal struct FetchPassbookTemplate: Decodable {
        internal let passbook: ActitoInternals.PushAPI.Models.Passbook
    }
}
