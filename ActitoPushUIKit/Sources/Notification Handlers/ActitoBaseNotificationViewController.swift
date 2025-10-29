//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import UIKit

public class ActitoBaseNotificationViewController: UIViewController {
    internal var notification: ActitoNotification!

    public private(set) var theme: ActitoOptions.Theme?

    internal private(set) var actionsButton: UIBarButtonItem?

    internal var isActionsButtonEnabled: Bool = false {
        didSet {
            renderNavigationBarItems()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        theme = Actito.shared.options!.theme(for: self)

        // Update the view controller's title.
        title = notification.title ?? Bundle.main.applicationName

        // Check if we should show any possible actions
        isActionsButtonEnabled = !notification.actions.isEmpty

        if let colorStr = theme?.backgroundColor {
            view.backgroundColor = UIColor(hexString: colorStr)
        } else {
            view.backgroundColor = .systemBackground
        }
    }

    @objc internal func dismissViewController() {
        dismiss(animated: true)
    }

    @objc internal func showActions() {
        let alert: UIAlertController

        if UIDevice.current.userInterfaceIdiom == .pad, let actionsButton {
            alert = UIAlertController(
                title: Bundle.main.applicationName,
                message: notification.message,
                preferredStyle: .actionSheet
            )

            alert.modalPresentationStyle = .popover
            alert.popoverPresentationController?.barButtonItem = actionsButton
            alert.popoverPresentationController?.permittedArrowDirections = .up
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            alert = UIAlertController(
                title: Bundle.main.applicationName,
                message: notification.message,
                preferredStyle: .actionSheet
            )

            alert.modalPresentationStyle = .currentContext
        } else {
            alert = UIAlertController(
                title: Bundle.main.applicationName,
                message: notification.message,
                preferredStyle: .alert
            )
        }

        notification.actions.forEach { action in
            alert.addAction(
                UIAlertAction(title: ActitoLocalizable.string(resource: action.label, fallback: action.label),
                              style: .default,
                              handler: { _ in self.handleAction(action) })
            )
        }

        alert.addAction(
            UIAlertAction(title: ActitoLocalizable.string(resource: .cancelButton),
                          style: .cancel,
                          handler: nil)
        )

        present(alert, animated: true, completion: nil)
    }

    internal func handleAction(_ action: ActitoNotification.Action) {
        Actito.shared.pushUI().presentAction(action, for: notification, in: self)
    }

    internal func hasActitoQueryParameters(in url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        guard let queryItems = components.queryItems else {
            return false
        }

        return queryItems.contains { item -> Bool in
            if item.name == "notificareCloseWindow" || item.name == Actito.shared.options!.closeWindowQueryParameter {
                return true
            } else if item.name == "notificareOpenActions", item.value == "1" || item.value == "true" {
                return true
            } else if item.name == "notificareOpenAction" {
                return true
            }

            return false
        }
    }

    internal func handleActitoQueryParameters(for url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        guard let queryItems = components.queryItems else {
            return
        }

        queryItems.forEach { item in
            if item.name == "notificareCloseWindow" || item.name == Actito.shared.options!.closeWindowQueryParameter {
                if item.value == "1" || item.value == "true" {
                    if let rootViewController = UIApplication.shared.rootViewController, rootViewController.presentedViewController != nil {
                        rootViewController.dismiss(animated: true, completion: nil)
                    } else {
                        navigationController?.popViewController(animated: true)
                    }
                }
            } else if item.name == "notificareOpenActions", item.value == "1" || item.value == "true" {
                showActions()
            } else if item.name == "notificareOpenAction" {
                // A query param to open a single action is present, let's loop over the actions and match the label.
                notification.actions.forEach { action in
                    if action.label == item.value {
                        handleAction(action)
                    }
                }
            }
        }
    }

    private func renderNavigationBarItems() {
        if Actito.shared.options?.legacyNotificationsUserInterfaceEnabled == true {
            renderLegacyNavigationBarItems()
            return
        }

        var leftBarButtonItem: UIBarButtonItem?
        var rightBarButtonItem: UIBarButtonItem?

        if isModal, isActionsButtonEnabled {
            leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(dismissViewController)
            )
        }

        if isModal, !isActionsButtonEnabled {
            rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(dismissViewController)
            )
        }

        if isActionsButtonEnabled {
            rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis"),
                style: .plain,
                target: self,
                action: #selector(showActions)
            )

            if let colorStr = theme?.actionButtonTextColor {
                rightBarButtonItem?.tintColor = UIColor(hexString: colorStr)
            }

            actionsButton = rightBarButtonItem
        } else {
            actionsButton = nil
        }

        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    private func renderLegacyNavigationBarItems() {
        guard isActionsButtonEnabled else {
            navigationItem.rightBarButtonItem = nil
            actionsButton = nil
            return
        }

        if let image = ActitoLocalizable.image(resource: .actions) {
            actionsButton = UIBarButtonItem(image: image,
                                            style: .plain,
                                            target: self,
                                            action: #selector(showActions))
        } else {
            actionsButton = UIBarButtonItem(title: ActitoLocalizable.string(resource: .actionsButton),
                                            style: .plain,
                                            target: self,
                                            action: #selector(showActions))
        }

        if let colorStr = theme?.actionButtonTextColor {
            actionsButton?.tintColor = UIColor(hexString: colorStr)
        }

        navigationItem.rightBarButtonItem = actionsButton
    }
}

// swiftlint:disable:next no_extension_access_modifier
private extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else {
            return false
        }
    }
}
