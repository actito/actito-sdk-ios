//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoInAppMessagingKit
import Testing

internal struct ActitoInAppMessageTest {
    @Test
    internal func testActitoInAppMessageSerialization() {
        let message = ActitoInAppMessage(
            id: "testId",
            name: "testName",
            type: "testType",
            context: ["testContext"],
            title: "testTitle",
            message: "testMessage",
            image: "testMessage",
            landscapeImage: "testLandscapeImage",
            delaySeconds: 0,
            primaryAction: ActitoInAppMessage.Action(
                label: "testLabel",
                destructive: true,
                url: "testUrl"
            ),
            secondaryAction: ActitoInAppMessage.Action(
                label: "testLabel",
                destructive: true,
                url: "testUrl"
            )
        )

        do {
            let convertedMessage = try ActitoInAppMessage.fromJson(json: message.toJson())

            #expect(message == convertedMessage)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoInAppMessageSerializationWithNilProps() {
        let message = ActitoInAppMessage(
            id: "testId",
            name: "testName",
            type: "testType",
            context: [],
            title: nil,
            message: nil,
            image: nil,
            landscapeImage: nil,
            delaySeconds: 0,
            primaryAction: nil,
            secondaryAction: nil
        )

        do {
            let convertedMessage = try ActitoInAppMessage.fromJson(json: message.toJson())

            #expect(message == convertedMessage)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionSerialization() {
        let action = ActitoInAppMessage.Action(
            label: "testLabel",
            destructive: true,
            url: "testUrl"
        )

        do {
            let convertedAction = try ActitoInAppMessage.Action.fromJson(json: action.toJson())

            #expect(action == convertedAction)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionSerializationWithNilProps() {
        let action = ActitoInAppMessage.Action(
            label: nil,
            destructive: true,
            url: nil
        )

        do {
            let convertedAction = try ActitoInAppMessage.Action.fromJson(json: action.toJson())

            #expect(action == convertedAction)
        } catch {
            Issue.record()
        }
    }
}
