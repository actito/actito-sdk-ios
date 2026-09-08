//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import Foundation
import OSLog

@MainActor
internal class DeviceViewModel: NSObject, ObservableObject {
    @Published internal private(set) var userMessages: [UserMessage] = []

    // Current Device

    @Published internal private(set) var currentDevice: ActitoDevice? = Actito.shared.device().currentDevice
    @Published internal private(set) var preferredLanguage: String? = Actito.shared.device().preferredLanguage
    @Published internal private(set) var userData: ActitoUserData?

    // Do Not Disturb

    @Published internal var hasDndEnabled = false
    @Published internal var startTime = ActitoTime.defaultStart.date
    @Published internal var endTime = ActitoTime.defaultEnd.date

    // User Registration

    @Published internal private(set) var isDeviceRegistered = false

    // Preferred Language

    @Published internal private(set) var hasPreferredLanguage = false

    override internal init() {
        super.init()

        Task { await fetchUserData() }

        checkCurrentUser()
        checkDndStatus()
        checkPreferredLanguage()
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
                    currentDevice = Actito.shared.device().currentDevice

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
                currentDevice = Actito.shared.device().currentDevice

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

    internal func updateUserData(_ data: [String: String?]) {
        Logger.main.info("Updating user data")

        Task {
            do {
                try await Actito.shared.device().updateUserData(data)
                Logger.main.info("Updated user data successfully")
                await fetchUserData()

                userMessages.append(
                    UserMessage(variant: .updateUserDataSuccess)
                )
            } catch {
                userMessages.append(
                    UserMessage(variant: .updateUserDataFailure)
                )
            }
        }
    }

    internal func registerAnonymousUser() {
        Logger.main.info("Registering device as Anonymous")

        Task {
            do {
                try await Actito.shared.device().updateUser(userId: nil, userName: nil)
                Logger.main.info("Device registerd as Anonymous successfully")
                currentDevice = Actito.shared.device().currentDevice
                isDeviceRegistered = false

                userMessages.append(
                    UserMessage(variant: .registerAnonymousSuccess)
                )
            } catch {
                Logger.main.info("Failed to register device as Anonymous")

                userMessages.append(
                    UserMessage(variant: .registerAnonymousFailure)
                )
            }
        }
    }

    internal func registerUser(userId: String, userName: String) {
        Logger.main.info("Registering device to user \(userName)")

        Task {
            do {
                try await Actito.shared.device().updateUser(
                    userId: userId,
                    userName: userName,
                )
                Logger.main.info("Registered device successfully")
                currentDevice = Actito.shared.device().currentDevice
                isDeviceRegistered = true

                userMessages.append(
                    UserMessage(variant: .registerDeviceSuccess)
                )
            } catch {
                userMessages.append(
                    UserMessage(variant: .registerDeviceFailure)
                )            }
        }
    }

    internal func updatePreferredLanguage(preferredLanguage: String) {
        Logger.main.info("Updating preferred language")

        Task {
            do {
                try await Actito.shared.device().updatePreferredLanguage(preferredLanguage)
                Logger.main.info("Preferred language update successfully")
                self.preferredLanguage = Actito.shared.device().preferredLanguage
                hasPreferredLanguage = true

                userMessages.append(
                    UserMessage(variant: .updatePreferredLanguageSuccess)
                )
            } catch {
                userMessages.append(
                    UserMessage(variant: .updatePreferredLanguageFailure)
                )
            }
        }
    }

    internal func clearPreferredLanguage() {
        Logger.main.info("Clearing preferred language")

        Task {
            do {
                try await Actito.shared.device().updatePreferredLanguage(nil)
                Logger.main.info("Preferred language cleared successfully")
                preferredLanguage = Actito.shared.device().preferredLanguage
                hasPreferredLanguage = false

                userMessages.append(
                    UserMessage(variant: .clearPreferredLanguageSuccess)
                )
            } catch {
                userMessages.append(
                    UserMessage(variant: .clearPreferredLanguageFailure)
                )
            }
        }
    }

    private func checkDndStatus() {
        let dnd = Actito.shared.device().currentDevice?.dnd
        guard let dnd = dnd else { return }

        startTime = dnd.start.date
        endTime = dnd.end.date
        hasDndEnabled = true
    }

    private func checkCurrentUser() {
        let device = Actito.shared.device().currentDevice
        isDeviceRegistered = device?.userId != nil
    }

    private func fetchUserData() async {
        Logger.main.info("Fetching user data")
        do {
            let data = try await Actito.shared.device().fetchUserData()
            Logger.main.info("User data fetched sucessfully")
            userData = data
        } catch {
            Logger.main.error("Failed to fetch user data")
        }
    }

    private func checkPreferredLanguage() {
        let preferredLanguage = Actito.shared.device().preferredLanguage
        hasPreferredLanguage = preferredLanguage != nil
    }
}

extension DeviceViewModel {
    internal func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    internal struct UserMessage: Equatable {
        internal let uniqueId = UUID().uuidString
        internal let variant: Variant

        internal enum Variant {
            case updateDoNotDisturbSuccess
            case updateDoNotDisturbFailure
            case clearDoNotDisturbSuccess
            case clearDoNotDisturbFailure
            case updateUserDataSuccess
            case updateUserDataFailure
            case registerDeviceSuccess
            case registerDeviceFailure
            case registerAnonymousSuccess
            case registerAnonymousFailure
            case updatePreferredLanguageSuccess
            case updatePreferredLanguageFailure
            case clearPreferredLanguageSuccess
            case clearPreferredLanguageFailure
        }
    }
}

extension ActitoDoNotDisturb {
    internal static var `default`: ActitoDoNotDisturb {
        ActitoDoNotDisturb(start: .defaultStart, end: .defaultEnd)
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
