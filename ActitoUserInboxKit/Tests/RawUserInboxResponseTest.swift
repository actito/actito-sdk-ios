//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
@testable import ActitoUserInboxKit
import Testing

internal struct RawUserInboxResponseTest {
    @Test
    internal func testRawUserInboxResponseToModel() {
        let expectedItem = ActitoUserInboxItem(
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

        let item = RawUserInboxResponse.RawUserInboxItem(
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
            expires: Date(timeIntervalSince1970: 1)
        ).toModel()

        #expect(expectedItem == item)
    }

    @Test
    internal func testRawUserInboxResponseWithNilPropsToModel() {
        let expectedItem = ActitoUserInboxItem(
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

        let item = RawUserInboxResponse.RawUserInboxItem(
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
            expires: nil
        ).toModel()

        #expect(expectedItem == item)
    }
}
