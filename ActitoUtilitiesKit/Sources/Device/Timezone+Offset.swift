//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension TimeZone {
    public var timeZoneOffset: Float {
        return Float(secondsFromGMT()) / 3600.0
    }
}
