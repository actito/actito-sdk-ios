//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension String {
    internal var isBlank: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
