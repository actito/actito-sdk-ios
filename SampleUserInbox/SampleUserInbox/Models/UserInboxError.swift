//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

internal enum UserInboxError: Error {
    case missingClientData
    case noDeviceIdAvailable
    case couldNotClearCredentials
    case noStoredCredentionals
}
