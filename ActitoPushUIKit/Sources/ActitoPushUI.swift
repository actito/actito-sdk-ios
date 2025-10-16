//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import SafariServices
import StoreKit
import UIKit

@MainActor
public final class ActitoPushUI {
    public static let shared = ActitoPushUI()

    private var latestPresentableNotificationHandler: ActitoNotificationPresenter?
    private var latestPresentableActionHandler: ActitoBaseActionHandler?

    // MARK: - Public API

    /// Specifies the delegate that handles notification lifecycle events
    ///
    /// This property allows setting a delegate conforming to ``ActitoPushUIDelegate`` to respond to various notification lifecycle events,
    /// such as when a notification is presented, actions are executed, or errors occur.
    public weak var delegate: ActitoPushUIDelegate?

    // MARK: Methods

    /// Presents a notification to the user.
    ///
    /// This method launches the UI for displaying the provided ``ActitoNotification`` on the provided ``UIViewController``.
    ///
    /// - Parameters:
    ///   - notification: The ``ActitoNotification`` to present.
    ///   - controller: The ``UIViewController`` in which to present the notification.
    public func presentNotification(_ notification: ActitoNotification, in controller: UIViewController) {
        logger.debug("Presenting notification '\(notification.id)'.")

        guard let type = ActitoNotification.NotificationType(rawValue: notification.type) else {
            logger.warning("Unhandled notification type '\(notification.type)'.")
            return
        }

        switch type {
        case .none:
            logger.debug("Attempting to present a notification of type 'none'. These should be handled by the application instead.")
            return

        case .alert:
            latestPresentableNotificationHandler = ActitoAlertController(notification: notification)

        case .inAppBrowser:
            latestPresentableNotificationHandler = ActitoInAppBrowserController(notification: notification)

        case .webView:
            let notificationController = ActitoWebViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .url:
            let notificationController = ActitoUrlViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .urlResolver:
            let result = NotificationUrlResolver.resolve(notification)

            switch result {
            case .none:
                logger.debug("Resolving as 'none' notification.")
                return

            case .urlScheme:
                logger.debug("Resolving as 'url scheme' notification.")
                latestPresentableNotificationHandler = ActitoUrlSchemeController(notification: notification)

            case .inAppBrowser:
                logger.debug("Resolving as 'in-app browser' notification.")
                latestPresentableNotificationHandler = ActitoInAppBrowserController(notification: notification)

            case .webView:
                logger.debug("Resolving as 'web view' notification.")

                let notificationController = ActitoUrlViewController()
                notificationController.notification = notification

                latestPresentableNotificationHandler = notificationController
            }

        case .urlScheme:
            latestPresentableNotificationHandler = ActitoUrlSchemeController(notification: notification)

        case .rate:
            latestPresentableNotificationHandler = ActitoRateController(notification: notification)

        case .image:
            let notificationController = ActitoImageGalleryViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .map:
            let notificationController = ActitoMapViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .passbook:
            do {
                if
                    ActitoInternals.Module.loyalty.isAvailable,
                    let module = ActitoInternals.Module.loyalty.klass?.instance,
                    let canPresent = try module.executeCommand("canPresentPasses", data: nil) as? Bool,
                    canPresent
                {
                    let data: [String: Any] = [
                        "controller": controller,
                        "notification": notification,
                    ]

                    _ = try module.executeCommand("present", data: data)

                    return
                }
            } catch {
                logger.error("Error executing loyalty commands", error: error)
            }

            let notificationController = ActitoWebPassViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .store:
            latestPresentableNotificationHandler = ActitoStoreController(notification: notification)

        case .video:
            let notificationController = ActitoVideoViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        @unknown default:
            logger.warning("Unknown notification type '\(notification.type)'.")
            return
        }

        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), willPresentNotification: notification)
        }

        latestPresentableNotificationHandler?.present(in: controller)
    }

    /// Presents an action associated with a notification.
    ///
    /// This method presents the UI for executing a specific ``ActitoNotification.Action`` associated with the provided ``ActitoNotification``.
    ///
    /// - Parameters:
    ///   - action: The ``ActitoNotification.Action`` to execute.
    ///   - notification: The ``ActitoNotification`` to present.
    ///   - controller: The ``UIViewController`` in which to present the action.
    public func presentAction(_ action: ActitoNotification.Action, for notification: ActitoNotification, in controller: UIViewController) {
        logger.debug("Presenting notification action '\(action.type)' for notification '\(notification.id)'.")

        guard let type = ActitoNotification.Action.ActionType(rawValue: action.type) else {
            logger.warning("Unhandled notification action type '\(action.type)'.")
            return
        }

        switch type {
        case .app:
            latestPresentableActionHandler = ActitoAppActionHandler(notification: notification,
                                                                    action: action,
                                                                    sourceViewController: controller)
        case .browser:
            latestPresentableActionHandler = ActitoBrowserActionHandler(notification: notification,
                                                                        action: action,
                                                                        sourceViewController: controller)
        case .callback:
            latestPresentableActionHandler = ActitoCallbackActionHandler(notification: notification,
                                                                         action: action,
                                                                         sourceViewController: controller)
        case .custom:
            latestPresentableActionHandler = ActitoCustomActionHandler(notification: notification,
                                                                       action: action,
                                                                       sourceViewController: controller)
        case .mail:
            latestPresentableActionHandler = ActitoMailActionHandler(notification: notification,
                                                                     action: action,
                                                                     sourceViewController: controller)
        case .sms:
            latestPresentableActionHandler = ActitoSmsActionHandler(notification: notification,
                                                                    action: action,
                                                                    sourceViewController: controller)
        case .telephone:
            latestPresentableActionHandler = ActitoTelephoneActionHandler(notification: notification,
                                                                          action: action,
                                                                          sourceViewController: controller)
        case .webView, .inAppBrowser:
            latestPresentableActionHandler = ActitoInAppBrowserActionHandler(notification: notification,
                                                                             action: action,
                                                                             sourceViewController: controller)

        @unknown default:
            logger.warning("Unknown notification action type '\(action.type)'.")
            return
        }

        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), willExecuteAction: action, for: notification)
        }

        latestPresentableActionHandler?.execute()
    }

    internal func createSafariViewController(url: URL, theme: ActitoOptions.Theme?) -> SFSafariViewController {
        let safariViewController: SFSafariViewController

        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true

        safariViewController = SFSafariViewController(url: url, configuration: configuration)

        if let theme = theme {
            if let colorStr = theme.safariBarTintColor {
                safariViewController.preferredBarTintColor = UIColor(hexString: colorStr)
            }

            if let colorStr = theme.safariControlsTintColor {
                safariViewController.preferredControlTintColor = UIColor(hexString: colorStr)
            }

            if
                let styleInt = Actito.shared.options!.safariDismissButtonStyle,
                let style = SFSafariViewController.DismissButtonStyle(rawValue: styleInt)
            {
                safariViewController.dismissButtonStyle = style
            }
        }

        return safariViewController
    }

}
