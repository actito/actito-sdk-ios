//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
@testable import ActitoInboxKit
import Testing

internal struct ActitoInboxItemTest {
    @Test
    internal func testActitoInboxItemSerialization() {
        let item = ActitoInboxItem(
            id: "testId",
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
            ),
            time: Date(timeIntervalSince1970: 1),
            opened: true,
            expires: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedItem = try ActitoInboxItem.fromJson(json: item.toJson())

            #expect(item == convertedItem)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoInboxItemSerializationWithNilProps() {
        let item = ActitoInboxItem(
            id: "testId",
            notification: ActitoNotification(
                partial: true,
                id: "testId",
                type: "testType",
                time: Date(timeIntervalSince1970: 1),
                title: nil,
                subtitle: nil,
                message: "testMessage",
                content: [],
                actions: [],
                attachments: [],
                extra: [:],
                targetContentIdentifier: nil
            ),
            time: Date(timeIntervalSince1970: 1),
            opened: true,
            expires: nil
        )

        do {
            let convertedItem = try ActitoInboxItem.fromJson(json: item.toJson())

            #expect(item == convertedItem)
        } catch {
            Issue.record()
        }
    }
}
