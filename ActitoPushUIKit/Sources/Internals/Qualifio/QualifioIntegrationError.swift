import Foundation

internal enum QualifioIntegrationError: Error {
    case integrationUnavailable
    case invocationFailed
}

extension QualifioIntegrationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .integrationUnavailable:
            return NSLocalizedString("Qualifio SDK is not implemented by the application.", comment: "")
        case .invocationFailed:
            return NSLocalizedString("Unable to invoke the integration with Qualifio.", comment: "")
        }
    }
}
