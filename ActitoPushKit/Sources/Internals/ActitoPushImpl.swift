//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Combine
import Foundation
import MobileCoreServices
import UIKit
import UserNotifications

internal class ActitoPushImpl: NSObject, ActitoModule, ActitoPush {
    private var notificationCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    private var _subscriptionStream: CurrentValueSubject<ActitoPushSubscription?, Never> = .init(LocalStorage.subscription)
    private var _allowedUIStream: CurrentValueSubject<Bool, Never> = .init(LocalStorage.allowedUI)

    internal let applicationDelegateInterceptor = ActitoPushAppDelegateInterceptor()
    internal let notificationCenterDelegate = ActitoNotificationCenterDelegate()
    internal let pushTokenRequester = PushTokenRequester()

    // MARK: - Actito Module

    internal static let instance = ActitoPushImpl()

    internal func migrate() {
        let allowedUI = UserDefaults.standard.bool(forKey: "notificareAllowedUI")

        LocalStorage.allowedUI = allowedUI
        LocalStorage.remoteNotificationsEnabled = UserDefaults.standard.bool(forKey: "notificareRegisteredForNotifications")

        if allowedUI {
            // Prevent the lib from sending the push registration event for existing devices.
            LocalStorage.firstRegistration = false
        }
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false

        if Actito.shared.options!.userNotificationCenterDelegateEnabled {
            logger.debug("Actito will set itself as the UNUserNotificationCenter delegate.")
            notificationCenter.delegate = notificationCenterDelegate
        } else {
            logger.warning("""
            Please configure your plist settings to allow Actito to become the UNUserNotificationCenter delegate. \
            Alternatively forward the UNUserNotificationCenter delegate events to Actito.
            """)
        }

        // Register interceptor to receive APNS swizzled events.
        _ = ActitoSwizzler.addInterceptor(applicationDelegateInterceptor)

        // Listen to 'application did become active'.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onApplicationForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        LocalStorage.clear()

        _subscriptionStream.value = LocalStorage.subscription
        _allowedUIStream.value = LocalStorage.allowedUI
    }

    internal func postLaunch() async throws {
        if hasRemoteNotificationsEnabled {
            logger.debug("Enabling remote notifications automatically.")
            try await updateDeviceSubscription()

            if await hasNotificationPermission() {
                await reloadActionCategories()
            }
        }
    }

    internal func unlaunch() async throws {
        // Unregister from APNS
        await UIApplication.shared.unregisterForRemoteNotifications()
        logger.info("Unregistered from APNS.")

        // Reset local storage
        LocalStorage.remoteNotificationsEnabled = false
        LocalStorage.firstRegistration = true

        self.transport = nil
        self.subscription = nil
        self.allowedUI = false

        notifySubscriptionUpdated(nil)
        notifyAllowedUIUpdated(false)
    }

    // MARK: Actito Push Module

    public weak var delegate: ActitoPushDelegate?

    public var subscriptionStream: AnyPublisher<ActitoPushSubscription?, Never> { _subscriptionStream.eraseToAnyPublisher() }
    public var allowedUIStream: AnyPublisher<Bool, Never> { _allowedUIStream.eraseToAnyPublisher() }

    public var authorizationOptions: UNAuthorizationOptions = [.badge, .sound, .alert]

    public var categoryOptions: UNNotificationCategoryOptions = {
        if #available(iOS 11.0, *) {
            return [.customDismissAction, .hiddenPreviewsShowTitle]
        } else {
            return [.customDismissAction]
        }
    }()

    public var presentationOptions: UNNotificationPresentationOptions = []

    public var hasRemoteNotificationsEnabled: Bool {
        LocalStorage.remoteNotificationsEnabled
    }

    public private(set) var transport: ActitoTransport? {
        get { LocalStorage.transport }
        set { LocalStorage.transport = newValue }
    }

    public private(set) var subscription: ActitoPushSubscription? {
        get { LocalStorage.subscription }
        set { LocalStorage.subscription = newValue }
    }

    public private(set) var allowedUI: Bool {
        get { LocalStorage.allowedUI }
        set { LocalStorage.allowedUI = newValue }
    }

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

    public func disableRemoteNotifications() async throws {
        try checkPrerequisites()

        // Keep track of the status in local storage.
        LocalStorage.remoteNotificationsEnabled = false

        try await updateDeviceSubscription(
            transport: .notificare,
            token: nil
        )

        // Unregister from APNS
        await UIApplication.shared.unregisterForRemoteNotifications()

        logger.info("Unregistered from push provider.")
    }

    public func isActitoNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        userInfo["x-sender"] as? String == "notificare"
    }

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

    private func notifySubscriptionUpdated(_ subscription: ActitoPushSubscription?) {
        DispatchQueue.main.async {
            self.delegate?.actito(self, didChangeSubscription: subscription)
        }

        _subscriptionStream.value = subscription
    }

    private func notifyAllowedUIUpdated(_ allowedUI: Bool) {
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

    internal func reloadActionCategories(_ completion: @escaping () -> Void) {
        logger.debug("Reloading action categories.")

        if Actito.shared.options?.preserveExistingNotificationCategories == true {
            notificationCenter.getNotificationCategories { existingCategories in
                let categories = existingCategories.union(self.loadAvailableCategories())
                self.notificationCenter.setNotificationCategories(categories)

                completion()
            }
        } else {
            let categories = loadAvailableCategories()
            notificationCenter.setNotificationCategories(categories)

            return
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

    @objc private func onApplicationForeground() {
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

    private func updateDeviceSubscription() async throws {
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

    private func hasNotificationPermission() async -> Bool {
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
