//
// Copyright (c) 2026 Actito. All rights reserved.
//

internal struct TestCustomEventsResponse: Decodable {
    internal let events: [Event]
    internal let count: Int

    internal struct Event: Decodable {
        internal let type: String
        internal let application: String
        internal let sessionID: String
        internal let data: [String: String]
        internal let time: String
        internal let deviceID: String
    }
}
