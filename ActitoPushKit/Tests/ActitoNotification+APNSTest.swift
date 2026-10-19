//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
@testable import ActitoPushKit
import Testing

internal struct ActitoNotificationAPNSTest {
    @Test
    internal func apnsDictionaryCreation() throws {
        let payload: [AnyHashable: Any] = [
            "aps": [
                "alert": [
                    "title": "Title",
                    "subtitle": "Subtitle",
                    "body": "Hello world",
                ],
            ],
            "id": "message-id",
            "notificationId": "notification-id",
            "notificationType": "re.notifica.notification.URL",
            "trackerId": "tracker-id",
            "inboxItemId": "inbox-id",
            "attachment": [
                "mimeType": "image/png",
                "uri": "https://example.com/image.png",
            ],
            "customKey": "custom-value",
            "x-internal": "ignored",
        ]

        let notification = try #require(ActitoNotification(apnsDictionary: payload))

        #expect(notification.partial)
        #expect(notification.id == "notification-id")
        #expect(notification.type == "re.notifica.notification.URL")
        #expect(notification.title == "Title")
        #expect(notification.subtitle == "Subtitle")
        #expect(notification.message == "Hello world")
        #expect(notification.attachments.count == 1)
        #expect(notification.attachments.first?.mimeType == "image/png")
        #expect(notification.attachments.first?.uri == "https://example.com/image.png")

        #expect(notification.trackerId == "tracker-id")

        #expect(notification.extra["trackerId"] == nil)

        #expect(notification.extra.count == 1)
        #expect(notification.extra["customKey"] as? String == "custom-value")
    }

    @Test(arguments: ["notificationId", "notificationType"])
    internal func apnsDictionaryCreationReturnsNilWhenRequiredKeyIsMissing(missingKey: String) {
        var payload: [AnyHashable: Any] = [
            "aps": ["alert": ["body": "Hello world"]],
            "notificationId": "notification-id",
            "notificationType": "re.notifica.notification.Alert",
        ]
        payload.removeValue(forKey: missingKey)

        #expect(ActitoNotification(apnsDictionary: payload) == nil)
    }

    @Test
    internal func apnsDictionaryCreationReturnsNilWhenAlertBodyIsMissing() {
        let payload: [AnyHashable: Any] = [
            "aps": ["alert": ["title": "Title"]],
            "notificationId": "notification-id",
            "notificationType": "re.notifica.notification.Alert",
        ]

        #expect(ActitoNotification(apnsDictionary: payload) == nil)
    }
}
