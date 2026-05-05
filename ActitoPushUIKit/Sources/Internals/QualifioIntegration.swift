import ActitoKit

private let CLASS_NAME = "QualifioKit.ActitoIntegration"
private let LAUNCH_CAMPAIGN_METHOD = "launchCampaignWithCampaign:"

@MainActor
internal final class QualifioIntegration {
    internal static let shared = QualifioIntegration()

    private var qClass: NSObject.Type? {
        NSClassFromString(CLASS_NAME) as? NSObject.Type
    }

    internal func handleCampaign(notification: ActitoNotification) throws {
        guard let content = notification.content.first else {
            throw QualifioIntegrationError.notificationContentNotDefined
        }

        switch content.type {
        case "re.notifica.content.qualifio.Campaign":
            guard let campaign = content.data as? String else {
                throw QualifioIntegrationError.notificationContentDataCampaignNotDefined
            }

            try launchCampaign(campaign)

        default:
            throw QualifioIntegrationError.notificationContentTypeUnknown(type: content.type)
        }
    }

    private func launchCampaign(_ campaign: String) throws {
        guard let qClass else {
            throw QualifioIntegrationError.classNotFound
        }

        let qualifio = qClass.init()
        let methodSelector: Selector = NSSelectorFromString(LAUNCH_CAMPAIGN_METHOD)

        guard qualifio.responds(to: methodSelector) else {
            throw QualifioIntegrationError.classMethodNotFound(name: LAUNCH_CAMPAIGN_METHOD)
        }

        _ = qualifio.perform(methodSelector, with: campaign)
    }
}
