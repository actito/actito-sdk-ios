//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import MessageUI

public class ActitoSmsActionHandler: ActitoBaseActionHandler {
    internal override func execute() {
        guard let target = action.target, MFMessageComposeViewController.canSendText() else {
            Task { @MainActor in
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.notSupported)
            }

            return
        }

        let recipients = target.components(separatedBy: ",")

        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = self
        composer.recipients = recipients
        composer.body = ""

        sourceViewController.presentOrPush(composer)

        Task {
            try? await Actito.shared.createNotificationReply(notification: notification, action: action)
        }
    }
}

extension ActitoSmsActionHandler: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            Task { @MainActor in
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
            }

        case .cancelled:
            Task { @MainActor in
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didNotExecuteAction: self.action, for: self.notification)
            }

        case .failed:
            Task { @MainActor in
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.failed)
            }

        default:
            Task { @MainActor in
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.failed)
            }
        }

        dismiss()
    }
}

extension ActitoSmsActionHandler {
    public enum ActionError: LocalizedError {
        case notSupported
        case failed

        public var errorDescription: String? {
            switch self {
            case .notSupported:
                return "The device does not support sending a SMS."
            case .failed:
                return "The message composer failed to send the SMS."
            }
        }
    }
}
