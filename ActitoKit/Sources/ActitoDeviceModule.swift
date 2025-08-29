//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation
import UIKit

@MainActor
public class ActitoDeviceModule {
    public static let shared = ActitoDeviceModule()

    internal private(set) var storedDevice: StoredDevice? {
        get { LocalStorage.device }
        set { LocalStorage.device = newValue }
    }

    internal var hasPendingDeviceRegistrationEvent: Bool?

    internal func resetLocalStorage() async throws {
        for module in ActitoInternals.Module.allCases {
            if let instance = module.klass?.instance {
                logger.debug("Resetting module: \(module)")

                do {
                    try await instance.clearStorage()
                } catch {
                    logger.debug("Failed to reset '\(module)'.", error: error)
                    throw error
                }
            }
        }

        try await Actito.shared.database.clear()

        // Should only clear device-related local storage properties.
        LocalStorage.device = nil
        LocalStorage.preferredLanguage = nil
        LocalStorage.preferredRegion = nil
    }

    // MARK: - Public API

    /// Provides the current registered device information.
    public var currentDevice: ActitoDevice? {
        storedDevice?.asPublic()
    }

    /// Provides the preferred language of the current device for notifications and messages.
    public var preferredLanguage: String? {
        guard let preferredLanguage = LocalStorage.preferredLanguage,
              let preferredRegion = LocalStorage.preferredRegion
        else {
            return nil
        }

        return "\(preferredLanguage)-\(preferredRegion)"
    }

    /// Registers a user for the device, with a callback.
    ///
    /// To register the device anonymously, set both `userId` and `userName` to `nil`.
    ///
    /// - Parameters:
    ///   - userId: Optional user identifier.
    ///   - userName: Optional user name.
    ///   - completion: A callback that will be invoked with the result of the register operation.
    @available(*, deprecated, renamed: "updateUser")
    public func register(userId: String?, userName: String?, _ completion: @escaping ActitoCallback<Void>) {
        updateUser(userId: userId, userName: userName, completion)
    }

    /// Registers a user for the device.
    ///
    /// To register the device anonymously, set both `userId` and `userName` to `nil`.
    ///
    /// - Parameters:
    ///   - userId: Optional user identifier.
    ///   - userName: Optional user name.
    @available(*, deprecated, renamed: "updateUser")
    public func register(userId: String?, userName: String?) async throws {
        try await updateUser(userId: userId, userName: userName)
    }

    /// Updates the user information for the device, with a callback.
    ///
    /// To register the device anonymously, set both `userId` and `userName` to `nil`.
    ///
    /// - Parameters:
    ///   - userId: Optional user identifier.
    ///   - userName: Optional user name.
    ///   - completion: A callback that will be invoked with the result of the update user operation.
    public func updateUser(userId: String?, userName: String?, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await updateUser(userId: userId, userName: userName)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Updates the user information for the device.
    ///
    /// To register the device anonymously, set both `userId` and `userName` to `nil`.
    ///
    /// - Parameters:
    ///   - userId: Optional user identifier.
    ///   - userName: Optional user name.
    public func updateUser(userId: String?, userName: String?) async throws {
        // TODO: try checkPrerequisites()

        guard Actito.shared.isReady else {
            throw ActitoError.notReady
        }

        guard var device = storedDevice else {
            throw ActitoError.deviceUnavailable
        }

        let payload = ActitoInternals.PushAPI.Payloads.UpdateDeviceUser(
            userID: userId,
            userName: userName
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        device.userId = userId
        device.userName = userName

        self.storedDevice = device
    }

    /// Updates the preferred language setting for the device, with a callback.
    /// - Parameters:
    ///   - preferredLanguage: The preferred language code, or `nil` to use the current local language.
    ///   - completion: A callback that will be invoked with the result of the update preferred language operation.
    public func updatePreferredLanguage(_ preferredLanguage: String?, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await updatePreferredLanguage(preferredLanguage)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Updates the preferred language setting for the device.
    /// - Parameter preferredLanguage: The preferred language code, or `nil` to use the current local language.
    public func updatePreferredLanguage(_ preferredLanguage: String?) async throws {
        guard Actito.shared.isReady else {
            throw ActitoError.notReady
        }

        if let preferredLanguage = preferredLanguage {
            let parts = preferredLanguage.components(separatedBy: "-")

            // TODO: improve language validator
            guard parts.count == 2 else {
                logger.error("Not a valid preferred language. Use a ISO 639-1 language code and a ISO 3166-2 region code (e.g. en-US).")
                throw ActitoError.invalidArgument(message: "Invalid preferred language value '\(preferredLanguage)'.")
            }

            let language = parts[0]
            let region = parts[1]

            // Only update if the value is not the same.
            guard language != LocalStorage.preferredLanguage, region != LocalStorage.preferredRegion else {
                return
            }

            try await updateLanguage(language, region: region)

            LocalStorage.preferredLanguage = language
            LocalStorage.preferredRegion = region
        } else {
            let language = Locale.current.deviceLanguage()
            let region = Locale.current.deviceRegion()

            try await updateLanguage(language, region: region)

            LocalStorage.preferredLanguage = nil
            LocalStorage.preferredRegion = nil
        }
    }

    /// Fetches the tags associated with the device, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the fetch tags operation.
    public func fetchTags(_ completion: @escaping ActitoCallback<[String]>) {
        Task {
            do {
                let result = try await fetchTags()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetches the tags associated with the device.
    ///
    /// - Returns: A list of tags currently associated with the device.
    public func fetchTags() async throws -> [String] {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let response = try await ActitoRequest.Builder()
            .get("/push/\(device.id)/tags")
            .responseDecodable(ActitoInternals.PushAPI.Responses.Tags.self)

        return response.tags
    }

    /// Adds a single tag to the device, with a callback.
    ///
    /// - Parameters:
    ///   - tag: The tag to add.
    ///   - completion: A callback that will be invoked with the result of the add tag operation.
    public func addTag(_ tag: String, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await addTag(tag)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Adds a single tag to the device.
    ///
    /// - Parameter tag: The tag to add.
    public func addTag(_ tag: String) async throws {
        try await addTags([tag])
    }

    /// Adds multiple tags to the device, with a callback.
    ///
    /// - Parameters:
    ///   - tags: A list of tags to add.
    ///   - completion: A callback that will be invoked with the result of the add tags operation.
    public func addTags(_ tags: [String], _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await addTags(tags)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Adds multiple tags to the device.
    ///
    /// - Parameter tags: A list of tags to add.
    public func addTags(_ tags: [String]) async throws {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let payload = ActitoInternals.PushAPI.Payloads.Device.Tags(
            tags: tags
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)/addtags", body: payload)
            .response()
    }

    /// Removes a specific tag from the device, with a callback
    ///
    /// - Parameters:
    ///   - tag: The tag to remove.
    ///   - completion: A callback that will be invoked with the result of the remove tag operation.
    public func removeTag(_ tag: String, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await removeTag(tag)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Removes a specific tag from the device.
    ///
    /// - Parameter tag: The tag to remove.
    public func removeTag(_ tag: String) async throws {
        try await removeTags([tag])
    }

    /// Removes multiple tags from the device, with a callback.
    ///
    /// - Parameters:
    ///   - tags: A list of tags to remove.
    ///   - completion: A callback that will be invoked with the result of the remove tags operation.
    public func removeTags(_ tags: [String], _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await removeTags(tags)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Removes multiple tags from the device.
    ///
    /// - Parameter tags: A list of tags to remove.
    public func removeTags(_ tags: [String]) async throws {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let payload = ActitoInternals.PushAPI.Payloads.Device.Tags(
            tags: tags
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)/removetags", body: payload)
            .response()
    }

    /// Clears all tags from the device, with a callback.
    ///
    /// - Parameter completion: A callback that will be invoked with the result of the clear tags operation.
    public func clearTags(_ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await clearTags()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Clears all tags from the device.
    public func clearTags() async throws {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)/cleartags")
            .response()
    }

    /// Fetches the "Do Not Disturb" (DND) settings for the device, with a callback.
    ///
    /// - Parameter completion: A callback that will be invoked with the result of the fetch dnd operation.
    public func fetchDoNotDisturb(_ completion: @escaping ActitoCallback<ActitoDoNotDisturb?>) {
        Task {
            do {
                let result = try await fetchDoNotDisturb()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetches the "Do Not Disturb" (DND) settings for the device.
    ///
    /// - Returns: The current DND settings, or `nil` if none are set.
    public func fetchDoNotDisturb() async throws -> ActitoDoNotDisturb? {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let response = try await ActitoRequest.Builder()
            .get("/push/\(device.id)/dnd")
            .responseDecodable(ActitoInternals.PushAPI.Responses.DoNotDisturb.self)

        // Update current device properties.
        storedDevice?.dnd = response.dnd

        return response.dnd
    }

    /// Updates the "Do Not Disturb" (DND) settings for the device, with a callback.
    ///
    /// - Parameters:
    ///   - dnd: The new DND settings to apply.
    ///   - completion: A callback that will be invoked with the result of the update dnd operation.
    public func updateDoNotDisturb(_ dnd: ActitoDoNotDisturb, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await updateDoNotDisturb(dnd)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Updates the "Do Not Disturb" (DND) settings for the device.
    ///
    /// - Parameter dnd: The new DND settings to apply.
    public func updateDoNotDisturb(_ dnd: ActitoDoNotDisturb) async throws {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let payload = ActitoInternals.PushAPI.Payloads.UpdateDeviceDoNotDisturb(
            dnd: dnd
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.dnd = dnd
    }

    /// Clears the "Do Not Disturb" (DND) settings for the device, with a callback.
    ///
    /// - Parameter completion: A callback that will be invoked with the result of the clear dnd operation.
    public func clearDoNotDisturb(_ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await clearDoNotDisturb()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Clears the "Do Not Disturb" (DND) settings for the device.
    public func clearDoNotDisturb() async throws {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let payload = ActitoInternals.PushAPI.Payloads.UpdateDeviceDoNotDisturb(
            dnd: nil
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.dnd = nil
    }

    /// Fetches the user data associated with the device, with a callback.
    ///
    /// - Parameter completion: A callback that will be invoked with the result of the fetch user data operation.
    public func fetchUserData(_ completion: @escaping ActitoCallback<ActitoUserData>) {
        Task {
            do {
                let result = try await fetchUserData()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetches the user data associated with the device.
    ///
    /// - Returns: The current user data.
    public func fetchUserData() async throws -> ActitoUserData {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let response = try await ActitoRequest.Builder()
            .get("/push/\(device.id)/userdata")
            .responseDecodable(ActitoInternals.PushAPI.Responses.UserData.self)

        let userData = response.userData?.compactMapValues { $0 } ?? [:]

        // Update current device properties.
        storedDevice?.userData = userData

        return userData
    }

    /// Updates the custom user data associated with the device, with a callback.
    ///
    /// - Parameters:
    ///   - userData: The updated user data to associate with the device.
    ///   - completion: A callback that will be invoked with the result of the update user data operation.
    public func updateUserData(_ userData: [String: String?], _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await updateUserData(userData)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Updates the custom user data associated with the device.
    ///
    /// - Parameter userData: The updated user data to associate with the device.
    public func updateUserData(_ userData: [String: String?]) async throws {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let payload = ActitoInternals.PushAPI.Payloads.UpdateDeviceUserData(
            userData: userData
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.userData = userData.compactMapValues { $0 }
    }

    // MARK: - Internal API

    // TODO: check prerequisites

    internal func createDevice() async throws {
        let backgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus

        let payload = ActitoInternals.PushAPI.Payloads.CreateDevice(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            platform: "iOS",
            osVersion: UIDevice.current.osVersion,
            sdkVersion: ACTITO_VERSION,
            appVersion: Bundle.main.applicationVersion,
            deviceString: UIDevice.current.deviceString,
            timeZoneOffset: TimeZone.current.timeZoneOffset,
            backgroundAppRefresh: backgroundRefreshStatus == .available
        )

        let response = try await ActitoRequest.Builder()
            .post("/push", body: payload)
            .responseDecodable(ActitoInternals.PushAPI.Responses.CreateDevice.self)

        self.storedDevice = StoredDevice(
            id: response.device.deviceID,
            userId: nil,
            userName: nil,
            timeZoneOffset: payload.timeZoneOffset,
            osVersion: payload.osVersion,
            sdkVersion: payload.sdkVersion,
            appVersion: payload.appVersion,
            deviceString: payload.deviceString,
            language: payload.language,
            region: payload.region,
            dnd: nil,
            userData: [:],
            backgroundAppRefresh: backgroundRefreshStatus == .available
        )
    }

    internal func updateDevice() async throws {
        guard var device = storedDevice else {
            throw ActitoError.deviceUnavailable
        }

        let backgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus

        let payload = ActitoInternals.PushAPI.Payloads.UpdateDevice(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            platform: "iOS",
            osVersion: UIDevice.current.osVersion,
            sdkVersion: ACTITO_VERSION,
            appVersion: Bundle.main.applicationVersion,
            deviceString: UIDevice.current.deviceString,
            timeZoneOffset: TimeZone.current.timeZoneOffset,
            backgroundAppRefresh: backgroundRefreshStatus == .available
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        device.language = payload.language
        device.region = payload.region
        device.osVersion = payload.osVersion
        device.sdkVersion = payload.sdkVersion
        device.appVersion = payload.appVersion
        device.deviceString = payload.deviceString
        device.timeZoneOffset = payload.timeZoneOffset
        device.backgroundAppRefresh = payload.backgroundAppRefresh

        self.storedDevice = device
    }

    internal func upgradeToLongLivedDeviceWhenNeeded() async throws {
        guard let device = LocalStorage.device, !device.isLongLived else {
            return
        }

        logger.info("Upgrading current device from legacy format.")

        let deviceId = device.id
        let transport = device.transport!
        let subscriptionId = transport != "Notificare" ? deviceId : nil

        let payload = ActitoInternals.PushAPI.Payloads.UpgradeToLongLivedDevice(
            deviceID: deviceId,
            transport: transport,
            subscriptionId: subscriptionId,
            language: device.language,
            region: device.region,
            platform: "iOS",
            osVersion: device.osVersion,
            sdkVersion: device.sdkVersion,
            appVersion: device.appVersion,
            deviceString: device.deviceString,
            timeZoneOffset: device.timeZoneOffset,
            backgroundAppRefresh: device.backgroundAppRefresh
        )

        let (response, data) = try await ActitoRequest.Builder()
            .post("/push", body: payload)
            .response()

        let generatedDeviceId: String

        if response.statusCode == 201, let data {
            logger.debug("New device identifier created.")

            let decoder = JSONDecoder.actito
            let decoded =  try decoder.decode(ActitoInternals.PushAPI.Responses.CreateDevice.self, from: data)

            generatedDeviceId = decoded.device.deviceID
        } else {
            generatedDeviceId = device.id
        }

        self.storedDevice = StoredDevice(
            id: generatedDeviceId,
            userId: device.userId,
            userName: device.userName,
            timeZoneOffset: device.timeZoneOffset,
            osVersion: device.osVersion,
            sdkVersion: device.sdkVersion,
            appVersion: device.appVersion,
            deviceString: device.deviceString,
            language: device.language,
            region: device.region,
            dnd: device.dnd,
            userData: device.userData,
            backgroundAppRefresh: device.backgroundAppRefresh
        )
    }

    internal func delete() async throws {
        // TODO: checkPrerequisites()

        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        try await ActitoRequest.Builder()
            .delete("/push/\(device.id)")
            .response()

        // Remove current device.
        storedDevice = nil
    }

    internal func updateTimezone() async throws {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let payload = ActitoInternals.PushAPI.Payloads.Device.UpdateTimeZone(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            timeZoneOffset: TimeZone.current.timeZoneOffset
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.timeZoneOffset = payload.timeZoneOffset
    }

    internal func updateLanguage(_ language: String, region: String) async throws {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let payload = ActitoInternals.PushAPI.Payloads.Device.UpdateLanguage(
            language: language,
            region: region
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.language = payload.language
        storedDevice?.region = payload.region
    }

    internal func updateBackgroundAppRefresh() async throws {
        guard Actito.shared.isReady, let device = storedDevice else {
            throw ActitoError.notReady
        }

        let backgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus

        let payload = ActitoInternals.PushAPI.Payloads.Device.UpdateBackgroundAppRefresh(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            backgroundAppRefresh: backgroundRefreshStatus == .available
        )

        try await ActitoRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.backgroundAppRefresh = payload.backgroundAppRefresh
    }

    internal func registerTestDevice(nonce: String) async throws {
        guard let device = storedDevice else {
            throw ActitoError.notReady
        }

        let payload = ActitoInternals.PushAPI.Payloads.TestDeviceRegistration(
            deviceID: device.id
        )

        try await ActitoRequest.Builder()
            .put("/support/testdevice/\(nonce)", body: payload)
            .response()
    }

    private func getDeviceLanguage() -> String {
        LocalStorage.preferredLanguage ?? Locale.current.deviceLanguage()
    }

    private func getDeviceRegion() -> String {
        LocalStorage.preferredRegion ?? Locale.current.deviceRegion()
    }

    // MARK: - Notification Center listeners

    @objc internal func updateDeviceTimezone() {
        logger.info("Device timezone changed.")

        Task {
            try? await updateTimezone()
            logger.info("Device timezone updated.")
        }
    }

    @objc internal func updateDeviceLanguage() {
        logger.info("Device language changed.")

        let language = getDeviceLanguage()
        let region = getDeviceRegion()

        Task {
            try? await updateLanguage(language, region: region)
            logger.info("Device language updated.")
        }
    }

    @objc internal func updateDeviceBackgroundAppRefresh() {
        logger.info("Device background app refresh status changed.")

        Task {
            try? await updateBackgroundAppRefresh()
            logger.info("Device background app refresh status updated.")
        }
    }
}
