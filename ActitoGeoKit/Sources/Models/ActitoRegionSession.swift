//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

public struct ActitoRegionSession: Codable, Equatable {
    public let regionId: String
    public let start: Date
    public let end: Date?
    public let locations: [ActitoLocation]
}
