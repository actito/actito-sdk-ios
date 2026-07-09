//
// Copyright (c) 2026 Actito. All rights reserved.
//

internal struct TestDeviceResponse: Decodable {
    internal let device: Device

    internal struct Device: Decodable {
        internal let userID: String
        internal let language: String
    }
}
