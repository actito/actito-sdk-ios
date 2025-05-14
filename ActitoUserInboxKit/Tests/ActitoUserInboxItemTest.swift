//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
@testable import ActitoUserInboxKit
import Testing

internal struct ActitoUserInboxItemTest {
    @Test
    internal func testActitoUserInboxSerialization() {
        let item = ActitoUserInboxItem(
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
            let convertedItem = try ActitoUserInboxItem.fromJson(json: item.toJson())

            #expect(item == convertedItem)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoUserInboxSerializationWithNullProps() {
        let item = ActitoUserInboxItem(
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
            let convertedItem = try ActitoUserInboxItem.fromJson(json: item.toJson())

            #expect(item == convertedItem)
        } catch {
            Issue.record()
        }
    }
}
