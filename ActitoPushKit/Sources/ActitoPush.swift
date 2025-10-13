//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Combine
import Foundation
import MobileCoreServices
import UIKit
import UserNotifications

@MainActor
public final class ActitoPush {
    public static let shared = ActitoPush()

    internal var notificationCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    internal let _subscriptionStream: CurrentValueSubject<ActitoPushSubscription?, Never> = .init(LocalStorage.subscription)
    internal let _allowedUIStream: CurrentValueSubject<Bool, Never> = .init(LocalStorage.allowedUI)

    internal let applicationDelegateInterceptor = ActitoPushAppDelegateInterceptor()
    internal let notificationCenterDelegate = ActitoNotificationCenterDelegate()
    internal let pushTokenRequester = PushTokenRequester()

    // MARK: - Public API

    /// Specifies the delegate that handles push notifications events
    ///
    /// This property allows setting a delegate conforming to ``ActitoPushDelegate`` to respond to various push notification events,
    /// such as receiving, opening, or interacting with notifications.
    public weak var delegate: ActitoPushDelegate?

    /// Defines the authorization options used when requesting push notification permissions.
    public var authorizationOptions: UNAuthorizationOptions = [.badge, .sound, .alert]

    /// Defines the notification category options for custom notification actions.
    public var categoryOptions: UNNotificationCategoryOptions = {
        if #available(iOS 11.0, *) {
            return [.customDismissAction, .hiddenPreviewsShowTitle]
        } else {
            return [.customDismissAction]
        }
    }()

    /// Defines the presentation options for displaying notifications while the app is in the foreground.
    public var presentationOptions: UNNotificationPresentationOptions = {
        if #available(iOS 14.0, *) {
            return [.banner, .badge, .sound]
        } else {
            return [.alert, .badge, .sound]
        }
    }()

    /// Indicates whether remote notifications are enabled.
    ///
    /// This property returns `true` if remote notifications are enabled for the application, and `false` otherwise.
    ///
    public var hasRemoteNotificationsEnabled: Bool {
        LocalStorage.remoteNotificationsEnabled
    }

    /// Provides the current push transport information.
    ///
    /// This property returns the ``ActitoTransport`` assigned to the device.
    ///
    public internal(set) var transport: ActitoTransport? {
        get { LocalStorage.transport }
        set { LocalStorage.transport = newValue }
    }

    /// Provides the current push subscription token.
    ///
    /// This property returns the ``ActitoPushSubscription`` object containing the device's current push subscription
    /// token, or `nil` if no token is available.
    ///
    public internal(set) var subscription: ActitoPushSubscription? {
        get { LocalStorage.subscription }
        set { LocalStorage.subscription = newValue }
    }

    /// This property returns a Publisher that can be observed to track changes to the device's push subscription token.
    public var subscriptionStream: AnyPublisher<ActitoPushSubscription?, Never> { _subscriptionStream.eraseToAnyPublisher() }

    /// Indicates whether the device is capable of receiving remote notifications.
    ///
    /// This property returns `true` if the user has granted permission to receive push notifications and the device
    /// has successfully obtained a push token from the notification service. It reflects whether the app can present
    /// notifications as allowed by the system and user settings.
    public internal(set) var allowedUI: Bool {
        get { LocalStorage.allowedUI }
        set { LocalStorage.allowedUI = newValue }
    }

    /// This property returns a Publisher that can be observed to track any changes to whether the device can receive remote notifications.
    public var allowedUIStream: AnyPublisher<Bool, Never> { _allowedUIStream.eraseToAnyPublisher() }

    /// Enables remote notifications, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the enable notifications operation.
    public func enableRemoteNotifications(_ completion: @escaping ActitoCallback<Bool>) {
        Task {
            do {
                let result = try await enableRemoteNotifications()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Enables remote notifications.
    ///
    /// - Returns: `true`if the remote notifications were enabled, `false` otherwise.
    public func enableRemoteNotifications() async throws -> Bool {
        try checkPrerequisites()

        // Keep track of the status in local storage.
        LocalStorage.remoteNotificationsEnabled = true

        // Request notification authorization options.
        let granted = try await notificationCenter.requestAuthorization(options: authorizationOptions)

        try await updateDeviceSubscription()

        if granted {
            logger.info("User granted permission to receive alerts, badge and sounds.")
            await reloadActionCategories()
        } else {
            logger.info("User did not grant permission to receive alerts, badge and sounds.")
        }

        return granted
    }

    /// Disables remote notifications, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the disable notifications operation.
    public func disableRemoteNotifications(_ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await disableRemoteNotifications()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Disables remote notifications.
    public func disableRemoteNotifications() async throws {
        try checkPrerequisites()

        // Keep track of the status in local storage.
        LocalStorage.remoteNotificationsEnabled = false

        try await updateDeviceSubscription(
            transport: .notificare,
            token: nil
        )

        // Unregister from APNS
        UIApplication.shared.unregisterForRemoteNotifications()

        logger.info("Unregistered from push provider.")
    }

    /// Determines whether a remote message is a Actito notification.
    ///
    /// - Parameters:
    ///   - userInfo: A dictionary containing the payload data of the notification.
    ///
    /// - Returns: `true` if the message is a Actito notification, `false` otherwise.
    public func isActitoNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        userInfo["x-sender"] as? String == "notificare"
    }

    /// Registers a live activity categorized by a list of topics, with a callback.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - topics: A list of topics to subscribe to.
    ///   - completion: A callback that will be called with the result of the register live activity operation.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: String, topics: [String], _ completion: @escaping ActitoCallback<Void>) {
        Task.init {
            do {
                try await registerLiveActivity(activityId, token: token, topics: topics)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Registers a live activity categorized by a list of topics.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - topics: A list of topics to subscribe to.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: String, topics: [String]) async throws {
        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        let payload = ActitoInternals.PushAPI.Payloads.RegisterLiveActivity(
            activity: activityId,
            token: token,
            deviceID: device.id,
            topics: topics
        )

        _ = try await ActitoRequest.Builder()
            .post("/live-activity", body: payload)
            .response()
    }

    /// Registers a live activity, with a callback.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - completion: A callback that will be called with the result of the register live activity operation.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: String, _ completion: @escaping ActitoCallback<Void>) {
        registerLiveActivity(activityId, token: token, topics: [], completion)
    }

    /// Registers a live activity.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: String) async throws {
        try await registerLiveActivity(activityId, token: token, topics: [])
    }

    /// Registers a live activity, with a callback.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - topics: A list of topics to subscribe to.
    ///   - completion: A callback that will be called with the result of the register live activity operation.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: Data, topics: [String] = [], _ completion: @escaping ActitoCallback<Void>) {
        registerLiveActivity(activityId, token: token.toHexString(), topics: topics, completion)
    }

    /// Registers a live activity.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - topics: A list of topics to subscribe to.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: Data, topics: [String] = []) async throws {
        try await registerLiveActivity(activityId, token: token.toHexString(), topics: topics)
    }

    /// Ends a live activity, with a callback.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to end.
    ///   - completion: A callback that will be invoked with the result of the end live activity operation.
    @available(iOS 16.1, *)
    public func endLiveActivity(_ activityId: String, _ completion: @escaping ActitoCallback<Void>) {
        Task.init {
            do {
                try await endLiveActivity(activityId)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Ends a live activity.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to end.
    @available(iOS 16.1, *)
    public func endLiveActivity(_ activityId: String) async throws {
        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        let encodedActivityId = activityId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let encodedDeviceId = device.id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!

        _ = try await ActitoRequest.Builder()
            .delete("/live-activity/\(encodedActivityId)/\(encodedDeviceId)")
            .response()
    }

    // MARK: Internal API

    internal func notifySubscriptionUpdated(_ subscription: ActitoPushSubscription?) {
        DispatchQueue.main.async {
            self.delegate?.actito(self, didChangeSubscription: subscription)
        }

        _subscriptionStream.value = subscription
    }

    internal func notifyAllowedUIUpdated(_ allowedUI: Bool) {
        DispatchQueue.main.async {
            self.delegate?.actito(self, didChangeNotificationSettings: allowedUI)
        }

        _allowedUIStream.value = allowedUI
    }

    private func checkPrerequisites() throws {
        if !Actito.shared.isReady {
            logger.warning("Actito is not ready yet.")
            throw ActitoError.notReady
        }

        guard let application = Actito.shared.application else {
            logger.warning("Actito application is not yet available.")
            throw ActitoError.applicationUnavailable
        }

        guard application.services[ActitoApplication.ServiceKey.apns.rawValue] == true else {
            logger.warning("Actito APNS functionality is not enabled.")
            throw ActitoError.serviceUnavailable(service: ActitoApplication.ServiceKey.apns.rawValue)
        }
    }

    internal func reloadActionCategories() async {
        logger.debug("Reloading action categories.")

        if Actito.shared.options?.preserveExistingNotificationCategories == true {
            let existingCategories = await notificationCenter.notificationCategories()

            let categories = existingCategories.union(loadAvailableCategories())
            notificationCenter.setNotificationCategories(categories)

            return
        } else {
            let categories = loadAvailableCategories()
            notificationCenter.setNotificationCategories(categories)

            return
        }
    }

    private func loadAvailableCategories() -> Set<UNNotificationCategory> {
        var categories = Set<UNNotificationCategory>()

        if #available(iOS 11.0, *) {
            categories.insert(
                UNNotificationCategory(
                    identifier: "ActitoDefaultCategory",
                    actions: [],
                    intentIdentifiers: [],
                    hiddenPreviewsBodyPlaceholder: ActitoLocalizable.string(resource: .pushDefaultCategory),
                    options: categoryOptions
                )
            )
        } else {
            categories.insert(
                UNNotificationCategory(
                    identifier: "ActitoDefaultCategory",
                    actions: [],
                    intentIdentifiers: [],
                    options: categoryOptions
                )
            )
        }

        // Loop over all the application info actionCategories list of Rich Push templates created for this application.
        Actito.shared.application?.actionCategories.forEach { category in
            let actions = category.actions.map { action -> UNNotificationAction in
                if action.destructive == true {
                    return buildNotificationAction(action, options: .destructive)
                } else if action.type == "re.notifica.action.Callback" {
                    // Check if needs camera or keyboard, if it does we will need to open the app.
                    if action.camera {
                        // Yeah let's set it to open the app.
                        return buildNotificationAction(action, options: [.foreground, .authenticationRequired])
                    } else if action.keyboard {
                        return buildTextInputNotificationAction(action, options: [])
                    } else {
                        // No need to open the app. Let's set it to be executed in the background and with no authentication required.
                        // This is mostly a Response or a Webhook request.
                        return buildNotificationAction(action, options: [])
                    }
                } else {
                    return buildNotificationAction(action, options: [.foreground, .authenticationRequired])
                }
            }

            if #available(iOS 11.0, *) {
                categories.insert(
                    UNNotificationCategory(
                        identifier: category.name,
                        actions: actions,
                        intentIdentifiers: [],
                        hiddenPreviewsBodyPlaceholder: ActitoLocalizable.string(resource: category.name, fallback: category.name),
                        options: categoryOptions
                    )
                )
            } else {
                categories.insert(
                    UNNotificationCategory(
                        identifier: category.name,
                        actions: actions,
                        intentIdentifiers: [],
                        options: categoryOptions
                    )
                )
            }
        }

        return categories
    }

    private func buildNotificationAction(_ action: ActitoNotification.Action, options: UNNotificationActionOptions) -> UNNotificationAction {
        if #available(iOS 15.0, *), let icon = action.icon?.ios {
            return UNNotificationAction(
                identifier: action.label,
                title: ActitoLocalizable.string(resource: action.label, fallback: action.label),
                options: options,
                icon: UNNotificationActionIcon(systemImageName: icon)
            )
        }

        return UNNotificationAction(
            identifier: action.label,
            title: ActitoLocalizable.string(resource: action.label, fallback: action.label),
            options: options
        )
    }

    private func buildTextInputNotificationAction(_ action: ActitoNotification.Action, options: UNNotificationActionOptions) -> UNTextInputNotificationAction {
        if #available(iOS 15.0, *), let icon = action.icon?.ios {
            return UNTextInputNotificationAction(
                identifier: action.label,
                title: ActitoLocalizable.string(resource: action.label, fallback: action.label),
                options: options,
                icon: UNNotificationActionIcon(systemImageName: icon),
                textInputButtonTitle: ActitoLocalizable.string(resource: .sendButton),
                textInputPlaceholder: ActitoLocalizable.string(resource: .actionsInputPlaceholder)
            )
        }

        return UNTextInputNotificationAction(
            identifier: action.label,
            title: ActitoLocalizable.string(resource: action.label, fallback: action.label),
            options: options,
            textInputButtonTitle: ActitoLocalizable.string(resource: .sendButton),
            textInputPlaceholder: ActitoLocalizable.string(resource: .actionsInputPlaceholder)
        )
    }

    @objc internal func onApplicationForeground() {
        guard Actito.shared.isReady else {
            return
        }

        Task {
            try? await updateDeviceNotificationSettings()
        }
    }

    private func fetchAttachment(for request: UNNotificationRequest, _ completion: @escaping ActitoCallback<UNNotificationAttachment>) {
        guard let attachment = request.content.userInfo["attachment"] as? [String: Any],
              let uri = attachment["uri"] as? String
        else {
            logger.warning("Could not find an attachment URI. Please ensure you're calling this method with the correct payload.")
            completion(.failure(ActitoError.invalidArgument(message: "Notification request has no attachment URI.")))
            return
        }

        guard let url = URL(string: uri) else {
            logger.warning("Invalid attachment URI. Please ensure it's a valid URL.")
            completion(.failure(ActitoError.invalidArgument(message: "Invalid attachment URI.")))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)[0]
            let fileName = url.pathComponents.last!
            let filePath = URL(fileURLWithPath: documentsPath).appendingPathComponent(fileName)

            guard let data = data, let response = response else {
                completion(.failure(ActitoError.invalidArgument(message: "Failed to download attachment from the provided URI.")))
                return
            }

            do {
                try data.write(to: filePath, options: .atomic)
            } catch {
                completion(.failure(ActitoError.invalidArgument(message: "Failed to download attachment from the provided URI.")))
                return
            }

            do {
                var options: [AnyHashable: Any] = [
                    UNNotificationAttachmentOptionsThumbnailClippingRectKey: CGRect(x: 0, y: 0, width: 1, height: 1),
                ]

                if
                    let mimeType = response.mimeType,
                    let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
                {
                    options[UNNotificationAttachmentOptionsTypeHintKey] = uti.takeRetainedValue()
                }

                let attachment = try UNNotificationAttachment(identifier: "file_\(fileName)", url: filePath, options: options)
                completion(.success(attachment))
            } catch {
                completion(.failure(ActitoError.invalidArgument(message: "Failed to download attachment from the provided URI.")))
                return
            }
        }.resume()
    }

    internal func updateDeviceSubscription() async throws {
        let token = try await pushTokenRequester.requestToken()

        try await updateDeviceSubscription(
            transport: .apns,
            token: token
        )
    }

    private func updateDeviceSubscription(transport: ActitoTransport, token: String?) async throws {
        logger.debug("Updating push subscription.")

        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        let previousTransport = self.transport
        let previousSubscription = self.subscription

        if previousTransport == transport && previousSubscription?.token == token {
            logger.debug("Push subscription unmodified. Updating notification settings instead.")
            try await updateDeviceNotificationSettings()
            return
        }

        let isPushCapable = transport != .notificare
        let hasPermission = await hasNotificationPermission()
        let allowedUI = isPushCapable && hasPermission

        let payload = ActitoInternals.PushAPI.Payloads.UpdateDeviceSubscription(
            transport: transport,
            subscriptionId: token,
            allowedUI: allowedUI
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        let subscription = token.map { ActitoPushSubscription(token: $0) }

        self.transport = transport
        self.subscription = subscription
        self.allowedUI = allowedUI

        notifySubscriptionUpdated(subscription)
        notifyAllowedUIUpdated(allowedUI)

        await ensureLoggedPushRegistration()
    }

    private func updateDeviceNotificationSettings() async throws {
        logger.debug("Updating user notification settings.")

        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        let previousAllowedUI = self.allowedUI

        let transport = self.transport
        let isPushCapable = transport != nil && transport != .notificare
        let hasPermission = await hasNotificationPermission()
        let allowedUI = isPushCapable && hasPermission

        if previousAllowedUI != allowedUI {
            let payload = ActitoInternals.PushAPI.Payloads.UpdateDeviceNotificationSettings(
                allowedUI: allowedUI
            )

            try await ActitoRequest.Builder()
                .put("/push/\(device.id)", body: payload)
                .response()

            logger.debug("User notification settings updated.")
            self.allowedUI = allowedUI

            notifyAllowedUIUpdated(allowedUI)
        } else {
            logger.debug("User notification settings update skipped, nothing changed.")
        }

        await ensureLoggedPushRegistration()
    }

    internal func hasNotificationPermission() async -> Bool {
        let settings = await notificationCenter.notificationSettings()

        var granted = settings.authorizationStatus == .authorized

        if #available(iOS 12.0, *) {
            if settings.authorizationStatus == .provisional {
                granted = true
            }
        }

        return granted
    }

    private func ensureLoggedPushRegistration() async {
        guard allowedUI, LocalStorage.firstRegistration else {
            return
        }

        do {
            // Ensure the flag update is immediate, preventing multiple simulatenous allowedUI updates
            // from triggering the event.
            LocalStorage.firstRegistration = false

            try await Actito.shared.events().logPushRegistration()
        } catch {
            logger.warning("Failed to log the push registration event.", error: error)
            LocalStorage.firstRegistration = true
        }
    }
}
