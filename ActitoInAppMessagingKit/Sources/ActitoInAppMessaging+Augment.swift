//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension Actito {
    public func inAppMessaging() -> ActitoInAppMessaging {
        ActitoInAppMessagingImpl.instance
    }
}
