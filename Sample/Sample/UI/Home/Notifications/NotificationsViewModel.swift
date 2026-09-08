//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoInboxKit
import ActitoKit
import Combine
import Foundation
import OSLog
import UserNotifications

@MainActor
internal class NotificationsViewModel: NSObject, ObservableObject {
    private let notificationCenter = UNUserNotificationCenter.current()

    @Published internal private(set) var userMessages: [UserMessage] = []
    @Published internal private(set) var badge = Actito.shared.inbox().badge

    @Published internal var hasNotificationsAndPermission = Actito.shared.push().allowedUI && Actito.shared.push().hasRemoteNotificationsEnabled
    @Published internal private(set) var hasNotificationsEnabled = Actito.shared.push().hasRemoteNotificationsEnabled
    @Published internal private(set) var allowedUi = Actito.shared.push().allowedUI
    @Published internal private(set) var subscription = Actito.shared.push().subscription
    @Published internal private(set) var notificationsPermission: NotificationsPermissionStatus? = nil

    private var cancellables = Set<AnyCancellable>()

    override internal init() {
        super.init()

        Actito.shared.push().allowedUIStream
            .sink { [weak self] allowedUI in
                self?.checkNotificationsStatus()
                Logger.main.info("Combine publisher allowedUI: \(allowedUI)")
            }
            .store(in: &cancellables)

        Actito.shared.push().subscriptionStream
            .handleEvents(receiveOutput: { subscription in
                Logger.main.info("Combine publisher subscription: \(String(describing: subscription))")
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$subscription)

        // Listening for inbox items and badge updates

        Actito.shared.inbox().itemsStream
            .sink { items in
                Logger.main.info("Combine publisher inbox update. Total = \(items.count)")
            }
            .store(in: &cancellables)

        Actito.shared.inbox().badgeStream
            .handleEvents(receiveOutput: { badge in
                Logger.main.info("Combine publisher badge update. Unread = \(badge)")
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$badge)

        checkNotificationsStatus()
    }

    internal func updateNotificationsStatus(enabled: Bool) {
        Logger.main.info("Notifications Toggle switched \(enabled ? "ON" : "OFF")")

        if enabled {
            Logger.main.info("Checking notifications permission")

            Task {
                let status = await checkNotificationsPermissionStatus()

                if status == .permanentlyDenied {
                    Logger.main.info("Notification permission permanently denied, skipping enabling remote notifications")
                    hasNotificationsAndPermission = false

                    return
                }

                if status == .notDetermined {
                    Logger.main.info("Requesting notifications permission")

                    do {
                        let granted = try await notificationCenter.requestAuthorization(options: Actito.shared.push().authorizationOptions)

                        userMessages.append(
                            UserMessage(variant: .requestNotificationsPermissionSuccess)
                        )

                        switch granted {
                        case true:
                            Logger.main.info("Granted notifications permission")

                        case false:
                            Logger.main.error("Notifications permission request denied, skipping enabling remote notifications")
                            hasNotificationsAndPermission = false

                            return
                        }
                    } catch {
                        Logger.main.error("Failed to request notifications authorization: \(error)")
                        hasNotificationsAndPermission = false

                        userMessages.append(
                            UserMessage(variant: .requestNotificationsPermissionFailure)
                        )
                    }
                }

                Logger.main.info("Enabling remote notifications")

                do {
                    let result = try await Actito.shared.push().enableRemoteNotifications()
                    Logger.main.info("Successfully enabled remote notifications, result bool: \(result)")

                    userMessages.append(
                        UserMessage(variant: .enableRemoteNotificationsSuccess)
                    )
                } catch {
                    Logger.main.error("Failed to enable remote notifications: \(error)")

                    userMessages.append(
                        UserMessage(variant: .enableRemoteNotificationsFailure)
                    )
                }

                checkNotificationsStatus()
            }
        } else {
            Task {
                Logger.main.info("Disabling remote notifications")
                try await Actito.shared.push().disableRemoteNotifications()

                checkNotificationsStatus()
            }
        }
    }

    private func checkNotificationsPermissionStatus() async -> (NotificationsPermissionStatus) {
        await withCheckedContinuation { completion in
            UNUserNotificationCenter.current().getNotificationSettings { status in
                var permissionStatus = NotificationsPermissionStatus.denied

                if status.authorizationStatus == .notDetermined {
                    permissionStatus = NotificationsPermissionStatus.notDetermined
                }

                if status.authorizationStatus == .authorized {
                    permissionStatus = NotificationsPermissionStatus.granted
                }

                if status.authorizationStatus == .denied {
                    permissionStatus = NotificationsPermissionStatus.permanentlyDenied
                }

                completion.resume(returning: permissionStatus)
            }
        }
    }

    internal func checkNotificationsStatus() {
        Task {
            let status = await checkNotificationsPermissionStatus()

            hasNotificationsAndPermission = Actito.shared.push().hasRemoteNotificationsEnabled && status == .granted
            notificationsPermission = status
            hasNotificationsEnabled = Actito.shared.push().hasRemoteNotificationsEnabled
            allowedUi = Actito.shared.push().allowedUI
        }
    }
}

extension NotificationsViewModel {
    internal func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    internal struct UserMessage: Equatable {
        internal let uniqueId = UUID().uuidString
        internal let variant: Variant

        internal enum Variant {
            case requestNotificationsPermissionSuccess
            case requestNotificationsPermissionFailure
            case enableRemoteNotificationsSuccess
            case enableRemoteNotificationsFailure
        }
    }
}

extension NotificationsViewModel {
    internal enum NotificationsPermissionStatus: String, CaseIterable {
        case notDetermined = "permission_status_not_determined"
        case granted = "permission_status_granted"
        case denied = "permission_status_denied"
        case permanentlyDenied = "permission_status_permanently_denied"

        internal var localized: String {
            return NSLocalizedString(rawValue, comment: "")
        }
    }
}
