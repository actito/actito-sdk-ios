//
// Copyright (c) 2025 Actito. All rights reserved.
//


@testable import ActitoKit
import Testing

internal struct ActitoNotificationTest {
    @Test
    internal func testActitoNotificationSerialization() {
        let notification = ActitoNotification(
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

        do {
            let convertedNotification = try ActitoNotification.fromJson(json: notification.toJson())

            #expect(notification == convertedNotification)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoNotificationSerializationWithNilProps() {
        let notification = ActitoNotification(
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
        )

        do {
            let convertedNotification = try ActitoNotification.fromJson(json: notification.toJson())

            #expect(notification == convertedNotification)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testContentSerialization() {
        let content = ActitoNotification.Content(
            type: "testType",
            data: "testData"
        )

        do {
            let convertedContent = try ActitoNotification.Content.fromJson(json: content.toJson())

            #expect(content == convertedContent)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionSerialization() {
        let action = ActitoNotification.Action(
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
        )

        do {
            let convertedAction = try ActitoNotification.Action.fromJson(json: action.toJson())

            #expect(action == convertedAction)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionSerializationWithNilProps() {
        let action = ActitoNotification.Action(
            type: "testType",
            label: "testLabel",
            target: nil,
            keyboard: true,
            camera: true,
            destructive: nil,
            icon: nil
        )

        do {
            let convertedAction = try ActitoNotification.Action.fromJson(json: action.toJson())

            #expect(action == convertedAction)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testIconSerialization() {
        let icon = ActitoNotification.Action.Icon(
            android: "testAndroid",
            ios: "testIos",
            web: "testWeb"
        )

        do {
            let convertedIcon = try ActitoNotification.Action.Icon.fromJson(json: icon.toJson())

            #expect(icon == convertedIcon)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testIconSerializationWithNilProps() {
        let icon = ActitoNotification.Action.Icon(
            android: nil,
            ios: nil,
            web: nil
        )

        do {
            let convertedIcon = try ActitoNotification.Action.Icon.fromJson(json: icon.toJson())

            #expect(icon == convertedIcon)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testAttachmentSerialization() {
        let attachment = ActitoNotification.Attachment(
            mimeType: "testMimeType",
            uri: "testUri"
        )

        do {
            let convertedAttachment = try ActitoNotification.Attachment.fromJson(json: attachment.toJson())

            #expect(attachment == convertedAttachment)
        } catch {
            Issue.record()
        }
    }
}
