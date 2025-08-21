//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    @MainActor
    public func pushUI() -> ActitoPushUI {
        ActitoPushUI.shared
    }
}
