import ActitoKit

@MainActor
internal final class QualifioIntegration {
    internal static let shared = QualifioIntegration()

    internal func handleCampaign(notification: ActitoNotification) async throws {
        guard let content = notification.content.first(where: { $0.type == "re.notifica.content.qualifio.Campaign" }) else {
            throw QualifioIntegrationError.notificationContentNotDefined
        }

        guard let campaign = content.data as? String else {
            throw QualifioIntegrationError.notificationCampaignNotDefined
        }

        try await invokeQualifio(campaign)
    }

    private func invokeQualifio(_ campaign: String) async throws {
        guard let qClass = NSClassFromString("QualifioKit.ActitoIntegration") as? NSObject.Type else {
            throw QualifioIntegrationError.classNotFound
        }

        let qualifio = qClass.init()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let completion: @Sendable (Error?) -> Void = { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }

            QualifioIntegrationBridge.invoke(
                qualifio,
                selectorName: "launchCampaign:completion:",
                campaign: campaign,
                completion: completion
            )
        }
    }
}
