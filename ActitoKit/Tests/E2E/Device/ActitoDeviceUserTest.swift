//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

@MainActor
@Suite(.serialized, ActitoConfigurationTrait(workflow: .launch, mode: .perTest))
internal struct ActitoDeviceUserTest {
    private let sampleUserId = "testuserid"
    private let sampleUserName = "TestUserName"

    @Test("ensure initially user is anonymous")
    internal func ensureInitiallyUserIsAnonymous() {
        let currentDevice = Actito.shared.device().currentDevice
        #expect(currentDevice != nil)

        #expect(currentDevice?.userId == nil)
        #expect(currentDevice?.userName == nil)
    }

    @Test("assign device to user")
    internal func assignDeviceToUser() async throws {
        try await Actito.shared.device().updateUser(userId: sampleUserId, userName: sampleUserName)

        let currentDevice = Actito.shared.device().currentDevice
        #expect(currentDevice != nil)

        let remoteUserId = try await getRemoteUserId()

        #expect(currentDevice?.userId == sampleUserId)
        #expect(currentDevice?.userName == sampleUserName)
        #expect(remoteUserId == currentDevice?.userId)
    }

    @Test("assign device to anonymous")
    internal func assignDeviceToAnonymous() async throws {
        try await Actito.shared.device().updateUser(userId: sampleUserId, userName: sampleUserName)
        try await Actito.shared.device().updateUser(userId: nil, userName: nil)

        let currentDevice = Actito.shared.device().currentDevice
        #expect(currentDevice != nil)

        let remoteUserId = try await getRemoteUserId()

        #expect(currentDevice?.userId == nil)
        #expect(currentDevice?.userName == nil)
        #expect(remoteUserId != sampleUserId)
    }

    private func getRemoteUserId() async throws -> String {
        guard let localDevice = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        let api = ActitoTestRestApiClient()
        let result = try await api.get(url: "/device/\(localDevice.id)")

        guard let data = result.data else {
            throw ActitoError.invalidArgument(message: "Empty response")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let device = json["device"] as? [String: Any],
              let userId = device["userID"] as? String
        else {
            throw ActitoError.invalidArgument(message: "Missing userID in response")
        }

        return userId
    }
}
