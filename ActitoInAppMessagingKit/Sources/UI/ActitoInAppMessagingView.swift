//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation
import UIKit

@MainActor
public protocol ActitoInAppMessagingView: UIView {
    // MARK: - Properties

    var message: ActitoInAppMessage { get }

    var delegate: ActitoInAppMessagingViewDelegate? { get set }

    // MARK: - Methods

    func present(in parentView: UIView)

    func animate(transition: ActitoInAppMessagingViewTransition)

    func animate(transition: ActitoInAppMessagingViewTransition, _ completion: @escaping () -> Void)

    func dismiss()

    func handleActionClicked(_ actionType: ActitoInAppMessage.ActionType)
}

extension ActitoInAppMessagingView {
    public func present(in parentView: UIView) {
        parentView.addSubview(self)
        parentView.bringSubviewToFront(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
        ])

        parentView.layoutIfNeeded()
        animate(transition: .enter)

        DispatchQueue.main.async {
            Actito.shared.inAppMessaging().delegate?.actito(Actito.shared.inAppMessaging(), didPresentMessage: self.message)
        }

        logger.debug("Tracking in-app message viewed event.")

        Task {
            do {
                try await Actito.shared.events().logInAppMessageViewed(message)
            } catch {
                logger.error("Failed to log in-message viewed event.", error: error)
            }
        }
    }

    public func animate(transition: ActitoInAppMessagingViewTransition) {
        animate(transition: transition) {}
    }

    public func dismiss() {
        animate(transition: .exit) {
            self.removeFromSuperview()
            self.delegate?.onViewDismissed()

            DispatchQueue.main.async {
                Actito.shared.inAppMessaging().delegate?.actito(Actito.shared.inAppMessaging(), didFinishPresentingMessage: self.message)
            }
        }
    }

    public func handleActionClicked(_ actionType: ActitoInAppMessage.ActionType) {
        let action: ActitoInAppMessage.Action?

        switch actionType {
        case .primary:
            action = message.primaryAction

        case .secondary:
            action = message.secondaryAction
        }

        guard let action = action else {
            logger.debug("There is no '\(actionType.rawValue)' action to process.")
            dismiss()

            return
        }

        guard let urlStr = action.url, let url = URL(string: urlStr) else {
            logger.debug("There is no URL for '\(actionType.rawValue)' action.")
            dismiss()

            return
        }

        Task {
            do {
                try await Actito.shared.events().logInAppMessageActionClicked(message, action: actionType)

                if UIApplication.shared.canOpenURL(url) {
                    if await UIApplication.shared.open(url, options: [:]) {
                        logger.info("In-app message action '\(actionType.rawValue)' successfully processed.")

                        DispatchQueue.main.async {
                            Actito.shared.inAppMessaging().delegate?.actito(Actito.shared.inAppMessaging(), didExecuteAction: action, for: self.message)
                        }
                    } else {
                        logger.warning("Unable to open the action's URL.")

                        DispatchQueue.main.async {
                            Actito.shared.inAppMessaging().delegate?.actito(Actito.shared.inAppMessaging(), didFailToExecuteAction: action, for: self.message, error: nil)
                        }
                    }
                } else {
                    logger.warning("Unable to open the action's URL.")

                    DispatchQueue.main.async {
                        Actito.shared.inAppMessaging().delegate?.actito(Actito.shared.inAppMessaging(), didFailToExecuteAction: action, for: self.message, error: nil)
                    }
                }

                dismiss()
            } catch {
                logger.error("Failed to log in-app message action.", error: error)
            }
        }
    }
}

@MainActor
public protocol ActitoInAppMessagingViewDelegate: AnyObject {
    func onViewDismissed()
}

public enum ActitoInAppMessagingViewTransition {
    case enter
    case exit
}
