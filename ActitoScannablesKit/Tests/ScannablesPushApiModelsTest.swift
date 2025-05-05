//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
@testable import ActitoScannablesKit
import Testing

internal struct ScannablesPushApiModelsTest {
    @Test
    internal func testScannableToModel() {
        let expectedScannable = ActitoScannable(
            id: "testId",
            name: "testName",
            tag: "testTag",
            type: "testType",
            notification: ActitoNotification(
                partial: false,
                id: "testId",
                type: "testType",
                time: Date(timeIntervalSince1970: 1),
                title: "testTitle",
                subtitle: "testSubtitle",
                message: "testMessage",
                content: [
                    ActitoNotification.Content(
                        type: "testType",
                        data: "testData"
                    ),
                ],
                actions: [
                    ActitoNotification.Action(
                        type: "testType",
                        label: "testLabel",
                        target: "testTarget",
                        keyboard: true,
                        camera: true,
                        destructive: true,
                        icon: ActitoNotification.Action.Icon(
                            android: "testAndroid",
                            ios: "testIos",
                            web: "testWeb")
                    ),
                ],
                attachments: [
                    ActitoNotification.Attachment(
                        mimeType: "testMimeType",
                        uri: "testUri"
                    ),
                ],
                extra: ["testExtraKey": "testExtraValue"],
                targetContentIdentifier: "testTargetIdentifier"
            )
        )

        let scannable = ActitoInternals.PushAPI.Models.Scannable(
            _id: "testId",
            name: "testName",
            type: "testType",
            tag: "testTag",
            data: ActitoInternals.PushAPI.Models.Scannable.ScannableData(
                notification: ActitoInternals.PushAPI.Models.Notification(
                    _id: "testId",
                    type: "testType",
                    time: Date(timeIntervalSince1970: 1),
                    title: "testTitle",
                    subtitle: "testSubtitle",
                    message: "testMessage",
                    content: [
                        ActitoNotification.Content(
                            type: "testType",
                            data: "testData"
                        ),
                    ],
                    actions: [
                        ActitoInternals.PushAPI.Models.Notification.Action(
                            type: "testType",
                            label: "testLabel",
                            target: "testTarget",
                            keyboard: true,
                            camera: true,
                            destructive: true,
                            icon: ActitoNotification.Action.Icon(
                                android: "testAndroid",
                                ios: "testIos",
                                web: "testWeb"
                            )
                        ),
                    ],
                    attachments: [
                        ActitoNotification.Attachment(
                            mimeType: "testMimeType",
                            uri: "testUri"
                        ),
                    ],
                    extra: ["testExtraKey": "testExtraValue"],
                    targetContentIdentifier: "testTargetIdentifier"
                )
            )
        ).toModel()

        #expect(expectedScannable == scannable)
    }

    @Test
    internal func testScannableWithNilPropsToModel() {
        let expectedScannable = ActitoScannable(
            id: "testId",
            name: "testName",
            tag: "testTag",
            type: "testType",
            notification: nil
        )

        let scannable = ActitoInternals.PushAPI.Models.Scannable(
            _id: "testId",
            name: "testName",
            type: "testType",
            tag: "testTag",
            data: nil
        ).toModel()

        #expect(expectedScannable == scannable)
    }
}
