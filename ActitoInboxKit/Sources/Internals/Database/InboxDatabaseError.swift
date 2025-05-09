//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

internal enum InboxDatabaseError: Error {
    case invalidArgument(_ argument: String, cause: Error?)
}
