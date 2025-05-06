//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension String {
    internal func isBlank() -> Bool {
        trimmingCharacters(in: .whitespaces).isEmpty
    }
}

extension Optional where Wrapped == String {
    internal func isNullOrBlank() -> Bool {
        guard let str = self else { return false }

        return str.isBlank()
    }
}
