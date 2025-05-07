//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation
import NotificationCenter

internal class ActitoNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    @MainActor
    internal func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo

        guard response.actionIdentifier != UNNotificationDismissActionIdentifier else {
            return
        }

        guard Actito.shared.push().isActitoNotification(userInfo) else {
            // Unrecognizable notification
            if response.actionIdentifier != UNNotificationDefaultActionIdentifier {
                let responseText = (response as? UNTextInputNotificationResponse)?.userText

                DispatchQueue.main.async {
                    Actito.shared.push().delegate?.actito(
                        Actito.shared.push(),
                        didOpenUnknownAction: response.actionIdentifier,
                        for: userInfo,
                        responseText: responseText
                    )
                }
            } else {
                DispatchQueue.main.async {
                    Actito.shared.push().delegate?.actito(
                        Actito.shared.push(),
                        didOpenUnknownNotification: userInfo
                    )
                }
            }

            return
        }

        guard let id = userInfo["id"] as? String else {
            logger.warning("Missing 'id' property in notification payload.")
            return
        }

        guard Actito.shared.isConfigured else {
            logger.warning("Actito has not been configured.")
            return
        }

        guard let application = Actito.shared.application else {
            logger.warning("Actito application unavailable. Ensure Actito is configured during the application launch.")
            return
        }

        guard application.id == userInfo["x-application"] as? String else {
            logger.warning("Incoming notification originated from another application.")
            return
        }

        let notification: ActitoNotification

        do {
            notification = try await Actito.shared.fetchNotification(id)
        } catch {
            logger.error("Failed to fetch notification with id '\(id)'.", error: error)

            if let partialNotification = ActitoNotification(apnsDictionary: userInfo) {
                notification = partialNotification
            } else {
                logger.debug("Unable to create a partial notification from the APNS payload.")
                return
            }
        }

        do {
            try await Actito.shared.events().logNotificationOpen(id)
        } catch {
            logger.error("Failed to log the notification as open.", error: error)
            return
        }

        if response.actionIdentifier != UNNotificationDefaultActionIdentifier {
            if let clickedAction = notification.actions.first(where: { $0.label == response.actionIdentifier }) {
                let responseText = (response as? UNTextInputNotificationResponse)?.userText

                if clickedAction.type == ActitoNotification.Action.ActionType.callback.rawValue, !clickedAction.camera, !clickedAction.keyboard || responseText != nil {
                    logger.debug("Handling a notification action without UI.")
                    handleQuickResponse(userInfo: userInfo, notification: notification, action: clickedAction, responseText: responseText)
                    return
                }

                do {
                    try await Actito.shared.events().logNotificationInfluenced(id)
                } catch {
                    logger.error("Failed to log the notification influenced open.", error: error)
                    return
                }

                InboxIntegration.markItemAsRead(userInfo: userInfo)

                DispatchQueue.main.async {
                    Actito.shared.push().delegate?.actito(Actito.shared.push(), didOpenAction: clickedAction, for: notification)
                }

                return
            }

            // Notify the inbox to update the badge.
            InboxIntegration.refreshBadge()
        } else {
            do {
                try await Actito.shared.events().logNotificationInfluenced(id)
            } catch {
                logger.error("Failed to log the notification influenced open.", error: error)
                return
            }

            InboxIntegration.markItemAsRead(userInfo: userInfo)

            DispatchQueue.main.async {
                Actito.shared.push().delegate?.actito(Actito.shared.push(), didOpenNotification: notification)
            }
        }
    }

    internal func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        guard Actito.shared.push().isActitoNotification(userInfo) else {
            // Unrecognizable notification
            return Actito.shared.push().presentationOptions
        }

        guard let application = Actito.shared.application else {
            logger.warning("Actito application unavailable. Ensure Actito is configured during the application launch.")
            return []
        }

        guard application.id == userInfo["x-application"] as? String else {
            logger.warning("Incoming notification originated from another application.")
            return []
        }

        // Check if we should force-set the presentation options.
        if let presentation = userInfo["presentation"] as? Bool, presentation {
            if #available(iOS 14.0, *) {
                return [.banner, .badge, .sound]
            } else {
                return [.alert, .badge, .sound]
            }
        }

        return Actito.shared.push().presentationOptions
    }

    internal func userNotificationCenter(_: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        guard let notification = notification else {
            DispatchQueue.main.async {
                Actito.shared.push().delegate?.actito(Actito.shared.push(), shouldOpenSettings: nil)
            }

            return
        }

        let userInfo = notification.request.content.userInfo

        guard Actito.shared.pushImplementation().isActitoNotification(userInfo) else {
            logger.debug("Cannot handle a notification from a provider other than Actito.")
            return
        }

        guard let id = userInfo["id"] as? String else {
            logger.warning("Missing 'id' property in notification payload.")
            return
        }

        guard Actito.shared.isConfigured else {
            logger.warning("Actito has not been configured.")
            return
        }

        Actito.shared.fetchNotification(id) { result in
            switch result {
            case let .success(notification):
                DispatchQueue.main.async {
                    Actito.shared.push().delegate?.actito(Actito.shared.push(), shouldOpenSettings: notification)
                }
            case .failure:
                logger.error("Failed to fetch notification with id '\(id)' for notification settings.")
            }
        }
    }

    private func handleQuickResponse(userInfo: [AnyHashable: Any], notification: ActitoNotification, action: ActitoNotification.Action, responseText: String?) {
        Task {
            try? await sendQuickResponse(notification: notification, action: action, responseText: responseText)

            // Remove the notification from the notification center.
            Actito.shared.removeNotificationFromNotificationCenter(notification)

            // Notify the inbox to mark the item as read.
            InboxIntegration.markItemAsRead(userInfo: userInfo)
        }
    }

    private func sendQuickResponse(notification: ActitoNotification, action: ActitoNotification.Action, responseText: String?) async throws {
        guard let target = action.target, let url = URL(string: target), url.scheme != nil, url.host != nil else {
            try await sendQuickResponseAction(notification: notification, action: action, responseText: responseText)
            return
        }

        var params = [
            "notificationID": notification.id,
            "label": action.label,
        ]

        if let responseText = responseText {
            params["message"] = responseText
        }

        do {
            try await Actito.shared.callNotificationReplyWebhook(url: url, data: params)
        } catch {
            logger.debug("Failed to call the notification reply webhook.", error: error)
        }

        try await sendQuickResponseAction(notification: notification, action: action, responseText: responseText)
    }

    private func sendQuickResponseAction(notification: ActitoNotification, action: ActitoNotification.Action, responseText: String?) async throws {
        do {
            try await Actito.shared.createNotificationReply(notification: notification, action: action, message: responseText, media: nil, mimeType: nil)
        } catch {
            logger.debug("Failed to create a notification reply.", error: error)
            throw error
        }
    }
}
