//
// Copyright (c) 2024 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

internal let logger: ActitoLogger = {
    var logger = ActitoLogger(
        subsystem: "com.actito",
        category: "Actito",
        labelIgnoreList: ["Actito"]
    )

    return logger
}()
