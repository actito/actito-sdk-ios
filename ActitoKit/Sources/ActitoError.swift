//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

public enum ActitoError: Error {
    case notConfigured
    case notReady
    case deviceUnavailable
    case applicationUnavailable
    case serviceUnavailable(service: String)
    case contentSizeTooLarge(message: String)

    // supporting errors
    case invalidArgument(message: String)
    case unsupportedCommand(message: String)
}
