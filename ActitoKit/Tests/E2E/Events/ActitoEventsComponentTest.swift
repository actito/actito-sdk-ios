//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import ActitoTestSupportKit
import Testing

@MainActor
@Suite(.serialized, ActitoConfigurationTrait(workflow: .launch, mode: .perSuite))
internal struct ActitoEventsComponentTest {

    @Test("events test invalid formats")
    internal func eventsTestInvalidFormats() async {
        let invalidEvents = [
            "te",
            "test.",
            "test&",
            ".test&",
            "test_test_test_test_test_test_test_test_test_test_test_test_test_test",
        ]

        for event in invalidEvents {
            let error = await #expect(throws: ActitoError.self) {
                try await Actito.shared.events().logCustom(event)
            }

            #expect({
                if case .invalidArgument = error { return true }
                return false
            }())
        }
    }

    @Test("events test large payload")
    internal func eventsTestLargePayload() async {
        let eventName = "test_event"
        let eventData = ["test_key": String(repeating: "a", count: 3000)]

        let error = await #expect(throws: ActitoError.self) {
            try await Actito.shared.events().logCustom(eventName, data: eventData)
        }

        #expect({
            if case .contentTooLarge = error { return true }
            return false
        }())
    }

    @Test("events log custom event")
    internal func eventsLogCustomEvent() async throws {
        let eventName = "test_event_data"
        let eventData = ["test_key": "test_value"]

        try await Actito.shared.events().logCustom(eventName, data: eventData)

        let deviceId = try #require(Actito.shared.device().currentDevice?.id)

        let result = try await ActitoTestRestApiClient.getDeviceCustomEvents(deviceId: deviceId, event: eventName)

        #expect(result.count == 1)
        #expect(result.events.first?.type == "re.notifica.event.custom.\(eventName)")
        #expect(result.events.first?.data == eventData)
    }
}
