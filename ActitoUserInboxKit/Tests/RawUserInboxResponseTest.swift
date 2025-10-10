//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
@testable import ActitoUserInboxKit
import Testing

internal struct RawUserInboxResponseTest {
    @Test
    internal func testRawUserInboxResponseToModel() throws {
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

        let jsonStr = """
            {
                "_id": "testId",
                "notification": "testNotification",
                "type": "testType",
                "time": "1970-01-01T00:00:01.000+0000",
                "title": "testTitle",
                "subtitle": "testSubtitle",
                "message": "testMessage",
                "attachment": {
                    "mimeType": "testMimeType",
                    "uri": "testUri"
                },
                "extra": {
                    "testKey": "testValue"
                },
                "opened": true,
                "expires": "1970-01-01T00:00:01.000+0000"
            }
            """

        let decoded = try JSONDecoder.actito.decode(RawUserInboxResponse.RawUserInboxItem.self, from: jsonStr.data(using: .utf8)!)

        let item = decoded.toModel()

        #expect(expectedItem == item)
    }

    @Test
    internal func testRawUserInboxResponseWithNilPropsToModel() throws {
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

        let jsonStr = """
            {
                "_id": "testId",
                "notification": "testNotification",
                "type": "testType",
                "time": "1970-01-01T00:00:01.000+0000",
                "title": null,
                "subtitle": null,
                "message": "testMessage",
                "attachment": null,
                "extra": {},
                "opened": true,
                "expires": null
            }
            """

        let decoded = try JSONDecoder.actito.decode(RawUserInboxResponse.RawUserInboxItem.self, from: jsonStr.data(using: .utf8)!)

        let item = decoded.toModel()

        #expect(expectedItem == item)
    }
}
