//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import ActitoTestSupportKit
import Testing

@MainActor
@Suite(.serialized, ActitoConfigurationTrait(workflow: .launch, mode: .perTest))
internal struct ActitoDeviceLanguageTest {
    private let samplePreferredLanguage = "pt"
    private let sampleLanguageRegion = "PT"

    @Test("ensure no preferred language set initially")
    internal func ensureNoPreferredLanguageSetInitially() async throws {
        let localPreferredLanguage = Actito.shared.device().preferredLanguage
        let remoteLanguage = try await ActitoTestRestApiClient.getRemoteDevice().language

        #expect(localPreferredLanguage == nil)
        #expect(remoteLanguage == Locale.current.deviceLanguage())
    }

    @Test("update preferred language")
    internal func updatePreferredLanguage() async throws {
        try await Actito.shared.device().updatePreferredLanguage("\(samplePreferredLanguage)-\(sampleLanguageRegion)")

        let localPreferredLanguage = Actito.shared.device().preferredLanguage
        let remoteLanguage = try await ActitoTestRestApiClient.getRemoteDevice().language

        #expect(localPreferredLanguage == "\(samplePreferredLanguage)-\(sampleLanguageRegion)")
        #expect(remoteLanguage == samplePreferredLanguage)
    }

    @Test("reset preferred language")
    internal func resetPreferredLanguage() async throws {
        try await Actito.shared.device().updatePreferredLanguage("\(samplePreferredLanguage)-\(sampleLanguageRegion)")
        try await Actito.shared.device().updatePreferredLanguage(nil)

        let localPreferredLanguage = Actito.shared.device().preferredLanguage
        let remoteLanguage = try await ActitoTestRestApiClient.getRemoteDevice().language

        #expect(localPreferredLanguage == nil)
        #expect(remoteLanguage == Locale.current.deviceLanguage())
    }
}
