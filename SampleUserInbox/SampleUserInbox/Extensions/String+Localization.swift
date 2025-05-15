//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension String {
    internal init(localized: String, comment: String = "", _ arguments: CVarArg...) {
        let localizedString = NSLocalizedString(localized, comment: comment)
        self = String(format: localizedString, arguments: arguments)
    }
}
