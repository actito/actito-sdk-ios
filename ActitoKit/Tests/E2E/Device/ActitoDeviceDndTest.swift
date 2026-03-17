//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import ActitoTestSupportKit
import Testing

@MainActor
@Suite(.serialized, ActitoConfigurationTrait(workflow: .launch, mode: .perTest))
internal struct ActitoDeviceDndTest {
    @Test("ensure initially no DnD set")
    internal func ensureInitiallyNoDnDSet() async throws {
        let localDnd = Actito.shared.device().currentDevice?.dnd
        let remoteDnd = try await Actito.shared.device().fetchDoNotDisturb()

        #expect(localDnd == nil)
        #expect(remoteDnd == nil)
    }

    @Test("update DnD")
    internal func updateDnD() async throws {
        let defaultDnd = ActitoDoNotDisturb(
            start: try ActitoTime(hours: 23, minutes: 0),
            end: try ActitoTime(hours: 8, minutes: 0)
        )

        try await Actito.shared.device().updateDoNotDisturb(defaultDnd)

        let localDnd = Actito.shared.device().currentDevice?.dnd
        let remoteDnd = try await Actito.shared.device().fetchDoNotDisturb()

        #expect(localDnd == defaultDnd)
        #expect(remoteDnd == defaultDnd)
    }

    @Test("clear DnD")
    internal func clearDnD() async throws {
        let defaultDnd = ActitoDoNotDisturb(
            start: try ActitoTime(hours: 23, minutes: 0),
            end: try ActitoTime(hours: 8, minutes: 0)
        )

        try await Actito.shared.device().updateDoNotDisturb(defaultDnd)
        try await Actito.shared.device().clearDoNotDisturb()

        let localDnd = Actito.shared.device().currentDevice?.dnd
        let remoteDnd = try await Actito.shared.device().fetchDoNotDisturb()

        #expect(localDnd == nil)
        #expect(remoteDnd == nil)
    }
}
