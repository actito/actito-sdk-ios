//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

@MainActor
@Suite(.serialized, ActitoConfigurationTrait(workflow: .launch, mode: .perTest))
internal struct ActitoDeviceUserDataTest {
    private let sampleFirstNameData = ["firstName": "Sample First Name"]
    private let sampleLastNameData = ["lastName": "Sample Last Name"]
    private let sampleUpdatedLastNameData = ["lastName": "Updated Sample Last Name"]

    private var sampleUserData: [String: String] {
        sampleFirstNameData.merging(sampleLastNameData) { _, new in new }
    }

    @Test("ensure initially no user data set")
    internal func ensureInitiallyNoUserDataSet() async throws {
        let userData = try await Actito.shared.device().fetchUserData()

        #expect(userData.isEmpty)
    }

    @Test("update user data")
    internal func updateUserData() async throws {
        try await Actito.shared.device().updateUserData(sampleUserData)

        let userData = try await Actito.shared.device().fetchUserData()

        #expect(userData.count == sampleUserData.count)
        #expect(userData == sampleUserData)
    }

    @Test("update existing user data")
    internal func updateExistingUserData() async throws {
        try await Actito.shared.device().updateUserData(sampleUserData)
        try await Actito.shared.device().updateUserData(sampleUpdatedLastNameData)

        let userData = try await Actito.shared.device().fetchUserData()

        #expect(userData.count == sampleUserData.count)
        #expect(userData["firstName"] == sampleUserData["firstName"])
        #expect(userData["lastName"] == sampleUpdatedLastNameData["lastName"])
    }

    @Test("remove one field in existing user data")
    internal func removeOneFieldInExistingUserData() async throws {
        try await Actito.shared.device().updateUserData(sampleUserData)

        try await Actito.shared.device().updateUserData([
            "lastName": nil
        ])

        let userData = try await Actito.shared.device().fetchUserData()

        #expect(userData.count == 1)
        #expect(userData["firstName"] == sampleUserData["firstName"])
    }

    @Test("clear existing user data")
    internal func clearExistingUserData() async throws {
        try await Actito.shared.device().updateUserData(sampleUserData)

        try await Actito.shared.device().updateUserData([
            "firstName": nil,
            "lastName": nil,
        ])

        let userData = try await Actito.shared.device().fetchUserData()

        #expect(userData.isEmpty)
    }
}
