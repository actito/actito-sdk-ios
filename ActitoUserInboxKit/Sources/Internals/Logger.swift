//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

internal var logger: ActitoLogger = {
    var logger = ActitoLogger(
        subsystem: "com.actito.inbox.user",
        category: "ActitoUserInbox"
    )

    logger.labelIgnoreList.append("ActitoUserInbox")

    return logger
}()
