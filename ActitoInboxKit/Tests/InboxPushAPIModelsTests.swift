//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoInboxKit
@testable import ActitoKit
import Testing

internal struct PushAPIModelsTest {
    @Test
    internal func testRemoteItemToLocalWithMissingExtras() throws {
        let expectedInboxItem = LocalInboxItem(
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
            visible: true,
            expires: nil,
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
                "opened": true,
                "visible": true,
                "expires": null
            }
        """

        let decoded = try JSONDecoder.actito.decode(ActitoInternals.PushAPI.Models.RemoteInboxItem.self, from: jsonStr.data(using: .utf8)!)

        let inboxItem = decoded.toLocal()

        #expect(expectedInboxItem == inboxItem)
    }
}
