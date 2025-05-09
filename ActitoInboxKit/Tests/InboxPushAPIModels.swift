//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
@testable import ActitoInboxKit
import Testing

internal struct InboxPushAPIModels {
    @Test
    internal func testRemoteInboxItemToModel() {
        let expectedItem = ActitoInboxItem(
            id: "testId",
            notification: ActitoNotification(
                partial: true,
                id: "testNotification",
                type: "testType",
                time: Date(timeIntervalSince1970: 1),
                title: "testTitle",
                subtitle: "testSubtitle",
                message: "testMessage",
                content: [],
                actions: [],
                attachments: [
                    ActitoNotification.Attachment(
                        mimeType: "testMimeType",
                        uri: "testUri"
                    ),
                ],
                extra: ["testKey": "testValue"],
                targetContentIdentifier: nil
            ),
            time: Date(timeIntervalSince1970: 1),
            opened: true,
            expires: Date(timeIntervalSince1970: 1)
        )

        let item = ActitoInternals.PushAPI.Models.RemoteInboxItem(
            _id: "testId",
            notification: "testNotification",
            type: "testType",
            time: Date(timeIntervalSince1970: 1),
            title: "testTitle",
            subtitle: "testSubtitle",
            message: "testMessage",
            attachment: ActitoNotification.Attachment(
                mimeType: "testMimeType",
                uri: "testUri"
            ),
            extra: ["testKey": "testValue"],
            opened: true,
            visible: true,
            expires: Date(timeIntervalSince1970: 1)
        ).toModel()

        #expect(expectedItem == item)
    }

    @Test
    internal func testRemoteInboxItemWithNullPropsToModel() {
        let expectedItem = ActitoInboxItem(
            id: "testId",
            notification: ActitoNotification(
                partial: true,
                id: "testNotification",
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

        let item = ActitoInternals.PushAPI.Models.RemoteInboxItem(
            _id: "testId",
            notification: "testNotification",
            type: "testType",
            time: Date(timeIntervalSince1970: 1),
            title: nil,
            subtitle: nil,
            message: "testMessage",
            attachment: nil,
            extra: [:],
            opened: true,
            visible: true,
            expires: nil
        ).toModel()

        #expect(expectedItem == item)
    }
}
