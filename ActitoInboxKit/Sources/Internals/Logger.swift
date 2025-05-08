//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

internal var logger: ActitoLogger = {
    var logger = ActitoLogger(
        subsystem: "com.actito.inbox",
        category: "ActitoInbox"
    )

    logger.labelIgnoreList.append("ActitoInbox")

    return logger
}()
