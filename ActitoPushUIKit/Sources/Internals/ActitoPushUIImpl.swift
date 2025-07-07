//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import SafariServices
import StoreKit
import UIKit

internal class ActitoPushUIImpl: ActitoPushUI {
    internal static let instance = ActitoPushUIImpl()

    private var latestPresentableNotificationHandler: ActitoNotificationPresenter?
    private var latestPresentableActionHandler: ActitoBaseActionHandler?

    // MARK: - Actito Push UI

    public weak var delegate: ActitoPushUIDelegate?

    //    func presentNotification(_ notification: ActitoNotification, in controller: UIViewController) {}
    //
    //    func presentNotification(_ notification: ActitoNotification, in window: UIWindow) {}
    //
    //    func presentNotification(_ notification: ActitoNotification, in scene: UIWindowScene) {}
    //
    //    func presentNotification(_ notification: ActitoNotification, in controller: UINavigationController) {}
    //
    //    func presentNotification(_ notification: ActitoNotification, in controller: UITabBarController, for tab: UITabBarItem) {}

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
            Task {
                do {
                    guard
                        ActitoInternals.Module.loyalty.isAvailable,
                        let module = ActitoInternals.Module.loyalty.klass?.instance,
                        let canPresent = try await module.executeCommand("canPresentPasses", data: nil) as? Bool,
                        canPresent
                    else {
                        await MainActor.run {
                            let notificationController = ActitoWebPassViewController()
                            notificationController.notification = notification

                            latestPresentableNotificationHandler = notificationController
                        }

                        return
                    }

                    let data: [String: Any] = [
                        "controller": controller,
                        "notification": notification,
                    ]

                    _ = try await module.executeCommand("present", data: data)
                } catch {
                    logger.error("Error executing loyalty commands", error: error)
                    return
                }
            }

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

        if #available(iOS 11.0, *) {
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = true

            safariViewController = SFSafariViewController(url: url, configuration: configuration)
        } else {
            safariViewController = SFSafariViewController(url: url)
        }

        if let theme = theme {
            if let colorStr = theme.safariBarTintColor {
                safariViewController.preferredBarTintColor = UIColor(hexString: colorStr)
            }

            if let colorStr = theme.safariControlsTintColor {
                safariViewController.preferredControlTintColor = UIColor(hexString: colorStr)
            }

            if #available(iOS 11.0, *) {
                if
                    let styleInt = Actito.shared.options!.safariDismissButtonStyle,
                    let style = SFSafariViewController.DismissButtonStyle(rawValue: styleInt)
                {
                    safariViewController.dismissButtonStyle = style
                }
            }
        }

        return safariViewController
    }
}
