//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoInAppMessagingKit
import ActitoKit
import ActivityKit
import Combine
import CoreLocation
import Foundation
import OSLog
import SwiftUI

@MainActor
internal class HomeViewModel: NSObject, ObservableObject {
    private let notificationCenter = UNUserNotificationCenter.current()

    @Published internal  private(set) var viewState: ViewState = .isNotReady
    @Published internal private(set) var userMessages: [UserMessage] = []

    // Launch Flow

    @Published internal private(set) var isConfigured = Actito.shared.isConfigured
    @Published internal private(set) var isReady = Actito.shared.isReady

    // Do not disturb

    @Published internal var hasDndEnabled = false
    @Published internal var startTime = ActitoTime.defaultStart.date
    @Published internal var endTime = ActitoTime.defaultEnd.date

    // In app messaging

    @Published internal var hasEvaluateContextOn = false
    @Published internal var hasSuppressedOn = false

    // Device registration

    @Published internal var userId = ""
    @Published internal var userName = ""
    @Published internal private(set) var isDeviceRegistered = false

    // Application Info

    @Published internal private(set) var applicationInfo: ApplicationInfo?

    private var cancellables = Set<AnyCancellable>()

    override internal init() {
        super.init()

        // Listening for actito ready

        NotificationCenter.default
            .publisher(for: .actitoStatus)
            .sink { [weak self] notification in
                guard let ready = notification.userInfo?["ready"] as? Bool else {
                    return
                }

                self?.isReady = ready
                self?.viewState = ready ? .isReady : .isNotReady
                self?.applicationInfo = self?.getApplicationInfo()
            }
            .store(in: &cancellables)

        // Load initial stats

        updateStats()

        applicationInfo = getApplicationInfo()
    }

    internal func updateStats() {
        checkDndStatus()
        checkCurrentDevice()
    }
}

// Launch Flow

extension HomeViewModel {
    internal func actitoLaunch() {
        Logger.main.info("Actito launch clicked")
        Actito.shared.launch { _ in }
    }

    internal func actitoUnlaunch() {
        Logger.main.info("Actito unlaunch clicked")
        Actito.shared.unlaunch { _ in }
    }
}

// Do Not Disturb

extension HomeViewModel {
    private func checkDndStatus() {
        let dnd = Actito.shared.device().currentDevice?.dnd
        guard let dnd = dnd else { return }

        startTime = dnd.start.date
        endTime = dnd.end.date
        hasDndEnabled = true
    }

    internal func updateDndStatus(enabled: Bool) {
        Logger.main.info("DnD Toggle switched \(enabled ? "ON" : "OFF")")

        if enabled {
            updateDndTime()
        } else {
            Logger.main.info("Clearing DnD")

            Task {
                do {
                    try await Actito.shared.device().clearDoNotDisturb()
                    Logger.main.info("DnD cleared successfully")

                    userMessages.append(
                        UserMessage(variant: .clearDoNotDisturbSuccess)
                    )
                } catch {
                    Logger.main.error("Failed to clear DnD: \(error)")

                    userMessages.append(
                        UserMessage(variant: .clearDoNotDisturbFailure)
                    )
                }
            }
        }
    }

    internal func updateDndTime() {
        Logger.main.info("Updating DnD time")

        Task {
            do {
                try await Actito.shared.device().updateDoNotDisturb(ActitoDoNotDisturb(start: ActitoTime(from: startTime), end: ActitoTime(from: endTime)))
                Logger.main.info("DnD updated successfully")

                userMessages.append(
                    UserMessage(variant: .updateDoNotDisturbSuccess)
                )
            } catch {
                Logger.main.error("Failed to update DnD: \(error)")

                userMessages.append(
                    UserMessage(variant: .updateDoNotDisturbFailure)
                )
            }
        }
    }
}

// In App Messaging

extension HomeViewModel {
    internal func updateSuppressedIamStatus(enabled: Bool) {
        Actito.shared.inAppMessaging().setMessagesSuppressed(enabled, evaluateContext: hasEvaluateContextOn)
    }
}

// Device Registration

extension HomeViewModel {
    private func checkCurrentDevice() {
        let device = Actito.shared.device().currentDevice

        userId = device?.userId ?? ""
        userName = device?.userName ?? ""
        isDeviceRegistered = device?.userId != nil
    }

    internal func registerDevice() {
        Logger.main.info("Registering device")

        Task {
            do {
                try await Actito.shared.device().updateUser(userId: userId, userName: userName.isEmpty ? nil : userName)
                isDeviceRegistered = true
                Logger.main.info("Device registered successfully")

                userMessages.append(
                    UserMessage(variant: .registerDeviceSuccess)
                )
            } catch {
                Logger.main.error("Failed to registered device: \(error)")

                userMessages.append(
                    UserMessage(variant: .registerDeviceFailure)
                )
            }
        }
    }

    internal func cleanDeviceRegistration() {
        Logger.main.info("Registering device as anonymous")

        Task {
            do {
                try await Actito.shared.device().updateUser(userId: nil, userName: nil)
                isDeviceRegistered = false
                userId = ""
                userName = ""

                userMessages.append(
                    UserMessage(variant: .registerDeviceSuccess)
                )
            } catch {
                Logger.main.error("Failed to registered device as anonymous: \(error)")

                userMessages.append(
                    UserMessage(variant: .registerDeviceFailure)
                )
            }
        }
    }
}

// Application Info

extension HomeViewModel {
    private func getApplicationInfo() -> ApplicationInfo? {
        guard let application = Actito.shared.application else {
            return nil
        }

        return ApplicationInfo(
            name: application.name,
            identifier: application.id
        )
    }
}

extension HomeViewModel {
    internal func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    internal enum ViewState {
        case isNotReady
        case isReady
    }

    internal struct UserMessage: Equatable {
        internal let uniqueId = UUID().uuidString
        internal let variant: Variant

        internal enum Variant {
            case requestNotificationsPermissionSuccess
            case requestNotificationsPermissionFailure
            case enableRemoteNotificationsSuccess
            case enableRemoteNotificationsFailure
            case clearDoNotDisturbSuccess
            case clearDoNotDisturbFailure
            case updateDoNotDisturbSuccess
            case updateDoNotDisturbFailure
            case registerDeviceSuccess
            case registerDeviceFailure
        }
    }
}

extension ActitoTime {
    internal init(from date: Date) {
        let hours = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)

        try! self.init(hours: hours, minutes: minutes)
    }

    internal var date: Date {
        Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date())!
    }

    internal static var defaultStart: ActitoTime {
        try! ActitoTime(hours: 23, minutes: 0)
    }

    internal static var defaultEnd: ActitoTime {
        try! ActitoTime(hours: 8, minutes: 0)
    }
}
