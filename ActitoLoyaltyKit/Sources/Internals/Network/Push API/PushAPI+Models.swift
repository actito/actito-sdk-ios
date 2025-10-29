//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import Foundation

extension ActitoInternals.PushAPI.Models {
    internal struct Pass: Decodable, Sendable {
        internal let _id: String
        internal let version: Int
        internal let passbook: String?
        internal let template: String?
        internal let serial: String
        internal let barcode: String
        internal let redeem: ActitoPass.Redeem
        internal let redeemHistory: [ActitoPass.Redemption]
        internal let limit: Int
        internal let token: String
        @ActitoExtraDictionary internal private(set) var data: [String: Any]?
        internal let date: Date
    }

    internal struct Passbook: Decodable {
        internal let passStyle: ActitoPass.PassType
    }
}
