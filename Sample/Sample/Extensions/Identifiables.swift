//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
