import Foundation

internal enum QualifioIntegrationError: Error {
    case classNotFound
    case notificationContentNotDefined
    case notificationCampaignNotDefined
}

extension QualifioIntegrationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .classNotFound:
            return NSLocalizedString("Qualifio SDK is not implemented by the application.", comment: "")
        case .notificationContentNotDefined:
            return NSLocalizedString("Qualifio campaign content is missing.", comment: "")
        case .notificationCampaignNotDefined:
            return NSLocalizedString("Campaign name is missing.", comment: "")
        }
    }
}
