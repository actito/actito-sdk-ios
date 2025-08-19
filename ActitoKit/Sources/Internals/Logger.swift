//
// Copyright (c) 2024 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

internal var logger: ActitoLogger = {
    var logger = ActitoLogger(
        subsystem: "com.actito",
        category: "Actito",
        labelIgnoreList: ["Actito"]
    )

    return logger
}()
