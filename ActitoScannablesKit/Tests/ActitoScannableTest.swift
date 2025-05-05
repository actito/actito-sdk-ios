//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
@testable import ActitoScannablesKit
import Testing

internal struct ActitoScannableTest {
    @Test
    internal func testActitoScannableSerialization() {
        let scannable = ActitoScannable(
            id: "testId",
            name: "testName",
            tag: "tesTag",
            type: "testType",
            notification: ActitoNotification(
                partial: true,
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

        do {
            let convertedScannable = try ActitoScannable.fromJson(json: scannable.toJson())

            #expect(scannable == convertedScannable)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoScannableSerializationWithNilProps() {
        let scannable = ActitoScannable(
            id: "testId",
            name: "testName",
            tag: "tesTag",
            type: "testType",
            notification: nil
        )

        do {
            let convertedScannable = try ActitoScannable.fromJson(json: scannable.toJson())

            #expect(scannable == convertedScannable)
        } catch {
            Issue.record()
        }
    }
}
