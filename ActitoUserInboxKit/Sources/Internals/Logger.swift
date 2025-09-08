//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

internal let logger: ActitoLogger = {
    var logger = ActitoLogger(
        subsystem: "com.actito.inbox.user",
        category: "ActitoUserInbox",
        labelIgnoreList: ["ActitoUserInbox"]
    )

    return logger
}()
