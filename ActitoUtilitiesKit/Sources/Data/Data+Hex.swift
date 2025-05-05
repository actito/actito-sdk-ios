//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension Data {
    public func toHexString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
