//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    public nonisolated func userInbox() -> ActitoUserInbox {
        ActitoUserInbox.shared
    }
}
