//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoInAppMessagingKit
@testable import ActitoKit
import Testing

internal struct PushAPIModelsTest {
    @Test
    internal func testMessageToModel() {
        let expectedMessage = ActitoInAppMessage(
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

        let message = ActitoInternals.PushAPI.Models.Message(
            _id: "testId",
            name: "testName",
            type: "testType",
            context: ["testContext"],
            title: "testTitle",
            message: "testMessage",
            image: "testMessage",
            landscapeImage: "testLandscapeImage",
            delaySeconds: 0,
            primaryAction: ActitoInternals.PushAPI.Models.Message.Action(
                label: "testLabel",
                destructive: true,
                url: "testUrl"
            ),
            secondaryAction: ActitoInternals.PushAPI.Models.Message.Action(
                label: "testLabel",
                destructive: true,
                url: "testUrl"
            )
        ).toModel()

        #expect(expectedMessage == message)
    }

    @Test
    internal func testMessageWithNilPropsToModel() {
        let expectedMessage = ActitoInAppMessage(
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

        let message = ActitoInternals.PushAPI.Models.Message(
            _id: "testId",
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
        ).toModel()

        #expect(expectedMessage == message)
    }
}
