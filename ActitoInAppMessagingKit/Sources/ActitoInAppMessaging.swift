//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation
import UIKit

@MainActor
public final class ActitoInAppMessaging {
    public nonisolated static let shared = ActitoInAppMessaging()

    private var presentedView: ActitoInAppMessagingView?
    private var presentedViewBackgroundTimestamp: Date?
    private var messageWorkItem: DispatchWorkItem?

    // MARK: - Public API

    /// Specifies the delegate that handles in-app messages lifecycle events
    ///
    /// This property allows setting a delegate conforming to ``ActitoInAppMessagingDelegate`` to respond to various in-app
    /// messages lifecycle events, such as presentation, completion, failures, and actions performed on the message.
    public weak var delegate: ActitoInAppMessagingDelegate?

    /// Indicates wheter in-app messages are currently suppressed.
    ///
    /// If *true*, message dispatching and the presentation of in-app messages are temporarily suspended.
    /// When *false*, in-app messages are allowed to be presented.
    public var hasMessagesSuppressed: Bool = false

    private nonisolated init() {}

    /// Sets the message suppression state
    ///
    /// When messages are suppressed, in-app messages will not be presented to the user.
    /// By default, stopping the in-app message suppression does not re-evaluate the foreground context.
    ///
    /// To trigger a new context evaluation after stopping in-app message suppression, set the `evaluateContext`
    /// parameter to `true`.
    ///
    /// - Parameters:
    ///   - suppressed: Set to *true* to supress in-app messages, or *false* to stop supressing them.
    ///   - evaluateContext: Set to *true* to re-evaluate the foreground context when stopping in-app messaging supression.
    public func setMessagesSuppressed(_ suppressed: Bool, evaluateContext: Bool) {
        if hasMessagesSuppressed == suppressed { return }

        hasMessagesSuppressed = suppressed

        if suppressed {
            if messageWorkItem != nil {
                logger.info("Clearing delayed in-app message from being presented when suppressed.")

                messageWorkItem?.cancel()
                messageWorkItem = nil
            }

            return
        }

        if evaluateContext {
            self.evaluateContext(.foreground)
        }
    }

    // MARK: - Private API

    internal func evaluateContext(_ context: ApplicationContext) {
        logger.debug("Checking in-app message for context '\(context.rawValue)'.")

        Task {
            do {
                let message = try await fetchInAppMessage(for: context)

                processInAppMessage(message)
            } catch {
                if case let ActitoNetworkError.validationError(response, _, _) = error, response.statusCode == 404 {
                    logger.debug("There is no in-app message for '\(context.rawValue)' context to process.")

                    if context == .launch {
                        self.evaluateContext(.foreground)
                    }

                    return
                }

                logger.error("Failed to process in-app message for context '\(context.rawValue)'.", error: error)
            }
        }
    }

    private func processInAppMessage(_ message: ActitoInAppMessage) {
        logger.info("Processing in-app message '\(message.name)'.")

        if message.delaySeconds > 0 {
            logger.debug("Waiting \(message.delaySeconds) seconds before presenting the in-app message.")

            let workItem = DispatchWorkItem {
                self.present(message)
                self.messageWorkItem = nil
            }

            // Keep a reference to the work item to cancel it when
            // the app goes into the background.
            messageWorkItem = workItem

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(message.delaySeconds), execute: workItem)
            return
        }

        present(message)
    }

    private func present(_ message: ActitoInAppMessage) {
        Task {
            let cache = ActitoImageCache()

            do {
                try await cache.preloadImages(for: message)
            } catch {
                logger.error("Failed to preload the in-app message images.", error: error)

                DispatchQueue.main.async {
                    self.delegate?.actito(self, didFailToPresentMessage: message)
                }

                return
            }

            present(message, cache: cache)
        }
    }

    private func present(_ message: ActitoInAppMessage, cache: ActitoImageCache) {
        guard presentedView == nil else {
            logger.warning("Cannot display an in-app message while another is being presented.")

            DispatchQueue.main.async {
                self.delegate?.actito(self, didFailToPresentMessage: message)
            }

            return
        }

        guard !hasMessagesSuppressed else {
            logger.debug("Cannot display an in-app message while messages are being suppressed.")

            DispatchQueue.main.async {
                self.delegate?.actito(self, didFailToPresentMessage: message)
            }

            return
        }

        guard let parentView = findParentView() else {
            logger.warning("Cannot display an in-app message without a reference to the parent view.")

            DispatchQueue.main.async {
                self.delegate?.actito(self, didFailToPresentMessage: message)
            }

            return
        }

        guard let view = self.createMessageView(for: message, cache: cache) else {
            logger.warning("Cannot display an in-app message without a view implementation for the given type.")

            DispatchQueue.main.async {
                self.delegate?.actito(self, didFailToPresentMessage: message)
            }

            return
        }

        view.delegate = self
        view.present(in: parentView)

        self.presentedView = view
    }

    private func fetchInAppMessage(for context: ApplicationContext) async throws -> ActitoInAppMessage {
        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        let response = try await ActitoRequest.Builder()
            .get("/inappmessage/forcontext/\(context.rawValue)")
            .query(name: "deviceID", value: device.id)
            .responseDecodable(ActitoInternals.PushAPI.Responses.InAppMessage.self)

        return response.message.toModel()
    }

    private func findParentView() -> UIView? {
        let window: UIWindow

        if #available(iOS 13.0, *) {
            guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
                logger.debug("Unable to acquire the first UIWindowScene.")
                return nil
            }

            if #available(iOS 15.0, *) {
                guard let keyWindow = scene.keyWindow else {
                    logger.debug("Unable to acquire the key window.")
                    return nil
                }

                window = keyWindow
            } else {
                guard let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) else {
                    logger.debug("Unable to acquire the key window.")
                    return nil
                }

                window = keyWindow
            }
        } else {
            guard let keyWindow = UIApplication.shared.delegate?.window ?? nil else {
                logger.debug("Unable to acquire the key window.")
                return nil
            }

            window = keyWindow
        }

        guard let rootViewController = window.rootViewController else {
            logger.debug("Unable to acquire the root view controller.")
            return nil
        }

        return rootViewController.view
    }

    private func createMessageView(for message: ActitoInAppMessage, cache: ActitoImageCache) -> ActitoInAppMessagingView? {
        let type = ActitoInAppMessage.MessageType(rawValue: message.type)

        switch type {
        case .banner:
            return ActitoInAppMessagingBannerView(message: message, cache: cache)

        case .card:
            return ActitoInAppMessagingCardView(message: message, cache: cache)

        case .fullscreen:
            return ActitoInAppMessagingFullscreenView(message: message, cache: cache)

        default:
            logger.warning("Unsupported in-app message type '\(message.type)'.")
            return nil
        }
    }

    @objc internal func onApplicationForeground() {
        if let presentedView = presentedView, let presentedViewBackgroundTimestamp = presentedViewBackgroundTimestamp {
            let now = Date().timeIntervalSince1970 * 1000
            let backgroundGracePeriod = Double(Actito.shared.options?.backgroundGracePeriodMillis ?? ActitoOptions.DEFAULT_IAM_BACKGROUND_GRACE_PERIOD_MILLIS)
            let expiredAt = presentedViewBackgroundTimestamp.timeIntervalSince1970 * 1000 + backgroundGracePeriod

            if now > expiredAt {
                logger.debug("Dismissing the current in-app message for being in the background for longer than the grace period.")
                presentedView.removeFromSuperview()

                self.presentedView = nil
                self.presentedViewBackgroundTimestamp = nil
            }
        }

        guard Actito.shared.isReady else {
            logger.debug("Postponing in-app message evaluation until Actito is launched.")
            return
        }

        guard presentedView == nil else {
            logger.debug("Skipping context evaluation since there is another in-app message being presented.")
            return
        }

        guard !hasMessagesSuppressed else {
            logger.debug("Skipping context evaluation since in-app messages are being suppressed.")
            return
        }

        evaluateContext(.foreground)
    }

    @objc internal func onApplicationBackground() {
        presentedViewBackgroundTimestamp = Date()

        if messageWorkItem != nil {
            logger.info("Clearing delayed in-app message from being presented when going to the background.")
            messageWorkItem?.cancel()
            messageWorkItem = nil
        }
    }
}

extension ActitoInAppMessaging: ActitoInAppMessagingViewDelegate {
    public func onViewDismissed() {
        presentedView = nil
    }
}
