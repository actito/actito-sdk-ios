//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit

extension ActitoInternals.PushAPI.Models {
    internal struct Scannable: Decodable, Equatable {
        internal let _id: String
        internal let name: String
        internal let type: String
        internal let tag: String
        internal let data: ScannableData?

        internal struct ScannableData: Decodable, Equatable {
            internal let notification: ActitoInternals.PushAPI.Models.Notification?
        }

        internal func toModel() -> ActitoScannable {
            ActitoScannable(
                id: _id,
                name: name,
                tag: tag,
                type: type,
                notification: data?.notification?.toModel()
            )
        }
    }
}
