//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import ActitoTestSupportKit
import Testing

@MainActor
@Suite(.serialized, ActitoConfigurationTrait(workflow: .launch, mode: .perTest))
internal struct ActitoDeviceUserTest {
    private let sampleUserId = "testuserid"
    private let sampleUserName = "TestUserName"

    @Test("ensure initially user is anonymous")
    internal func ensureInitiallyUserIsAnonymous() throws {
        let currentDevice = try #require(Actito.shared.device().currentDevice)

        #expect(currentDevice.userId == nil)
        #expect(currentDevice.userName == nil)
    }

    @Test("assign device to user")
    internal func assignDeviceToUser() async throws {
        try await Actito.shared.device().updateUser(userId: sampleUserId, userName: sampleUserName)

        let currentDevice = try #require(Actito.shared.device().currentDevice)

        let remoteUserId = try await ActitoTestRestApiClient.getRemoteDevice().userID

        #expect(currentDevice.userId == sampleUserId)
        #expect(currentDevice.userName == sampleUserName)
        #expect(remoteUserId == currentDevice.userId)
    }

    @Test("assign device to anonymous")
    internal func assignDeviceToAnonymous() async throws {
        try await Actito.shared.device().updateUser(userId: sampleUserId, userName: sampleUserName)
        try await Actito.shared.device().updateUser(userId: nil, userName: nil)

        let currentDevice = try #require(Actito.shared.device().currentDevice)

        let remoteUserId = try await ActitoTestRestApiClient.getRemoteDevice().userID

        #expect(currentDevice.userId == nil)
        #expect(currentDevice.userName == nil)
        #expect(remoteUserId != sampleUserId)
    }
}
