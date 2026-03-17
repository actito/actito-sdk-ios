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

        let api = ActitoTestRestApiClient()
        let result = try await api.get(url: "/event/fortype/re.notifica.event.custom.test_event_data")

        guard let data = result.data else {
            throw ActitoError.invalidArgument(message: "Empty response")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let events = json["events"] as? [[String: Any]],
              let lastEvent = events.first,
              let lastEventSessionId = lastEvent["sessionID"] as? String
        else {
            throw ActitoError.invalidArgument(message: "Missing userID in response")
        }

        #expect(lastEventSessionId == Actito.shared.session().sessionId)
    }
}
