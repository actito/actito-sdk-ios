//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

internal let logger: ActitoLogger = {
    var logger = ActitoLogger(
        subsystem: "com.actito.push",
        category: "ActitoPush",
        labelIgnoreList: ["ActitoPush"]
    )

    return logger
}()
