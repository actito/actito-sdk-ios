//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

@MainActor
@Suite(ActitoConfigurationTrait(workflow: .configurationOnly, mode: .perSuite))
internal struct ActitoDelegateTest {
    @Test("ensure events emmitted once")
    internal func ensureEventsEmittedOnce() async throws {
        let delegate = ActitoTestDelegate()
        Actito.shared.delegate = delegate

        try await Actito.shared.launch()

        await delegate.waitForLaunch()
        await delegate.waitForRegister()

        #expect(delegate.didLaunch == 1)
        #expect(delegate.didRegisterDevice == 1)
        #expect(delegate.didUnlaunch == 0)

        try await Actito.shared.unlaunch()

        await delegate.waitForUnlaunch()

        #expect(delegate.didLaunch == 1)
        #expect(delegate.didRegisterDevice == 1)
        #expect(delegate.didUnlaunch == 1)
    }

}

private class ActitoTestDelegate: ActitoDelegate {
    var didLaunch = 0
    var didUnlaunch = 0
    var didRegisterDevice = 0

    func actito(_ actito: Actito, onReady application: ActitoApplication) {
        print("did launch")
        didLaunch += 1
    }

    func actito(_ actito: Actito, didRegisterDevice device: ActitoDevice) {
        didRegisterDevice += 1
    }

    func actitoDidUnlaunch(_ actito: Actito) {
        didUnlaunch += 1
    }

    func waitForLaunch() async {
        while didLaunch == 0 {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    func waitForRegister() async {
        while didRegisterDevice == 0 {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    func waitForUnlaunch() async {
        while didUnlaunch == 0 {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
}
