//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

@MainActor
@Suite(.serialized, ActitoConfigurationTrait(workflow: .launch, mode: .perTest))
internal struct ActitoDeviceLanguageTest {
    private let samplePreferredLanguage = "pt"
    private let sampleLanguageRegion = "PT"

    @Test("ensure no preferred language set initially")
    internal func ensureNoPreferredLanguageSetInitially() async throws {
        let localPreferredLanguage = Actito.shared.device().preferredLanguage
        let remoteLanguage = try await getRemoteLanguage()

        #expect(localPreferredLanguage == nil)
        #expect(remoteLanguage == Locale.current.deviceLanguage())
    }

    @Test("update preferred language")
    internal func updatePreferredLanguage() async throws {
        try await Actito.shared.device().updatePreferredLanguage("\(samplePreferredLanguage)-\(sampleLanguageRegion)")

        let localPreferredLanguage = Actito.shared.device().preferredLanguage
        let remoteLanguage = try await getRemoteLanguage()

        #expect(localPreferredLanguage == "\(samplePreferredLanguage)-\(sampleLanguageRegion)")
        #expect(remoteLanguage == samplePreferredLanguage)
    }

    @Test("reset preferred language")
    internal func resetPreferredLanguage() async throws {
        try await Actito.shared.device().updatePreferredLanguage("\(samplePreferredLanguage)-\(sampleLanguageRegion)")
        try await Actito.shared.device().updatePreferredLanguage(nil)

        let localPreferredLanguage = Actito.shared.device().preferredLanguage
        let remoteLanguage = try await getRemoteLanguage()

        #expect(localPreferredLanguage == nil)
        #expect(remoteLanguage == Locale.current.deviceLanguage())
    }

    private func getRemoteLanguage() async throws -> String {
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
              let language = device["language"] as? String
        else {
            throw ActitoError.invalidArgument(message: "Missing language in response")
        }

        return language
    }
}
