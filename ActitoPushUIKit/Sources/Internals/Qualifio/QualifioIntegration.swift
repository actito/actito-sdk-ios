import ActitoKit

@MainActor
internal final class QualifioIntegration {
    internal static let shared = QualifioIntegration()

    internal func handleCampaign(notification: ActitoNotification) async throws {
        guard let content = notification.content.first(where: { $0.type == "re.notifica.content.qualifio.Campaign" }) else {
            throw ActitoError.invalidArgument(message: "Missing notification content.")
        }

        guard let campaign = content.data as? String else {
            throw ActitoError.invalidArgument(message: "Invalid notification content.")
        }

        try await invokeQualifio(campaign)
    }

    private func invokeQualifio(_ campaign: String) async throws {
        guard let qClass = NSClassFromString("QualifioKit.ActitoIntegration") as? NSObject.Type else {
            throw QualifioIntegrationError.integrationUnavailable
        }

        let qualifio = qClass.init()
        let selector = Selector(("launchCampaign:completion:"))

        guard qualifio.responds(to: selector) else {
            throw QualifioIntegrationError.integrationUnavailable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let exception = QualifioIntegrationBridge.try {
                let completion: @convention(block) (Error?) -> Void = { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }

                qualifio.perform(selector, with: campaign, with: completion)
            }

            if let exception {
                logger.warning("Failed to invoke the integration. Error: \(exception)")
                continuation.resume(throwing: QualifioIntegrationError.invocationFailed)
            }
        }
    }

}
