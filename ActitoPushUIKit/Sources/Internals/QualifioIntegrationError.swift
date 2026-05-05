import Foundation

internal enum QualifioIntegrationError: Error {
    case classNotFound
    case classMethodNotFound(name: String)
    case notificationContentNotDefined
    case notificationContentTypeUnknown(type: String)
    case notificationContentDataCampaignNotDefined
}

extension QualifioIntegrationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .classNotFound:
            return NSLocalizedString("Qualifio SDK is not implemented by the application.", comment: "")
        case let .classMethodNotFound(name):
            return NSLocalizedString("Qualifio SDK integration method '\(name)' not found.", comment: "")
        case .notificationContentNotDefined:
            return NSLocalizedString("Notification content is missing.", comment: "")
        case let .notificationContentTypeUnknown(type):
            return NSLocalizedString("Unknown content type: \(type).", comment: "")
        case .notificationContentDataCampaignNotDefined:
            return NSLocalizedString("Campaign name is missing.", comment: "")
        }
    }
}
