//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

internal struct PushAPIModelsTest {
    @Test
    internal func testActitoApplicationToModel() {
        let expectedApplication = ActitoApplication(
            id: "testId",
            name: "testName",
            category: "testCategory",
            appStoreId: "testAppStoreId",
            services: ["testKey": true],
            inboxConfig: ActitoApplication.InboxConfig(
                useInbox: true,
                useUserInbox: true,
                autoBadge: true
            ),
            regionConfig: ActitoApplication.RegionConfig(proximityUUID: "testUUID"),
            userDataFields: [
                ActitoApplication.UserDataField(
                    type: "testType",
                    key: "testKey",
                    label: "testLabel"
                ),
            ],
            actionCategories: [
                ActitoApplication.ActionCategory(
                    name: "testName",
                    description: "testDescription",
                    type: "testType",
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
                                ios: "testIOS",
                                web: "testWeb"
                            )
                        ),
                    ]
                ),
            ],
            enforceSizeLimit: true,
            enforceTagRestrictions: true,
            enforceEventNameRestrictions: true
        )

        let application = ActitoInternals.PushAPI.Models.Application(
            _id: "testId",
            name: "testName",
            category: "testCategory",
            appStoreId: "testAppStoreId",
            services: ["testKey": true],
            inboxConfig: ActitoApplication.InboxConfig(
                useInbox: true,
                useUserInbox: true,
                autoBadge: true
            ),
            regionConfig: ActitoApplication.RegionConfig(proximityUUID: "testUUID"),
            userDataFields: [
                ActitoApplication.UserDataField(
                    type: "testType",
                    key: "testKey",
                    label: "testLabel"
                ),
            ],
            actionCategories: [
                ActitoInternals.PushAPI.Models.Application.ActionCategory(
                    name: "testName",
                    description: "testDescription",
                    type: "testType",
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
                                ios: "testIOS",
                                web: "testWeb"
                            )
                        ),
                    ]
                ),
            ],
            enforceSizeLimit: true,
            enforceTagRestrictions: true,
            enforceEventNameRestrictions: true
        ).toModel()

        #expect(expectedApplication == application)
    }

    @Test
    internal func testActitoApplicationWithNilPropsToModel() {
        let expectedApplication = ActitoApplication(
            id: "testId",
            name: "testName",
            category: "testCategory",
            appStoreId: nil,
            services: [:],
            inboxConfig: nil,
            regionConfig: nil,
            userDataFields: [],
            actionCategories: [],
            enforceSizeLimit: true,
            enforceTagRestrictions: nil,
            enforceEventNameRestrictions: nil
        )

        let application = ActitoInternals.PushAPI.Models.Application(
            _id: "testId",
            name: "testName",
            category: "testCategory",
            appStoreId: nil,
            services: [:],
            inboxConfig: nil,
            regionConfig: nil,
            userDataFields: [],
            actionCategories: [],
            enforceSizeLimit: true,
            enforceTagRestrictions: nil,
            enforceEventNameRestrictions: nil
        ).toModel()

        #expect(expectedApplication == application)
    }

    @Test
    internal func testNotificationToModel() throws {
        let expectedNotification = ActitoNotification(
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

        let jsonStr = """
            {
                "_id": "testId",
                "type": "testType",
                "time": "1970-01-01T00:00:01.000+0000",
                "title": "testTitle",
                "subtitle": "testSubtitle",
                "message": "testMessage",
                "content": [
                    {
                        "type": "testType",
                        "data": "testData"
                    }
                ],
            "actions": [
                {
                    "type": "testType",
                    "label": "testLabel",
                    "target": "testTarget",
                    "keyboard": true,
                    "camera": true,
                    "destructive": true,
                    "icon": {
                        "android": "testAndroid",
                        "ios": "testIos",
                        "web": "testWeb"
                    }
                }
            ],
            "attachments": [
                {
                    "mimeType": "testMimeType",
                    "uri": "testUri"
                }
            ],
            "extra": {
                "testExtraKey": "testExtraValue"
            },
            "targetContentIdentifier": "testTargetIdentifier"
        }
        """

        let decoded = try JSONDecoder.actito.decode(ActitoInternals.PushAPI.Models.Notification.self, from: jsonStr.data(using: .utf8)!)

        let notification = decoded.toModel()

        #expect(expectedNotification == notification)
    }

    @Test
    internal func testNotificationWithNilPropsToModel() throws {
        let expectedNotification = ActitoNotification(
            partial: false,
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

        let jsonStr = """
            {
                "_id": "testId",
                "type": "testType",
                "time": "1970-01-01T00:00:01.000+0000",
                "title": null,
                "subtitle": null,
                "message": "testMessage",
                "content": [],
                "actions": [],
                "attachments": [],
                "extra": {},
                "targetContentIdentifier": null
            }
            """

        let decoded = try JSONDecoder.actito.decode(ActitoInternals.PushAPI.Models.Notification.self, from: jsonStr.data(using: .utf8)!)

        let notification = decoded.toModel()

        #expect(expectedNotification == notification)
    }

    @Test
    internal func testActionToModel() {
        let expectedAction = ActitoNotification.Action(
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

        let action = ActitoInternals.PushAPI.Models.Notification.Action(
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
        ).toModel()

        #expect(expectedAction == action)
    }

    @Test
    internal func testActionWithNilPropsToModel() {
        let expectedAction = ActitoNotification.Action(
            type: "testType",
            label: "testLabel",
            target: nil,
            keyboard: false,
            camera: false,
            destructive: nil,
            icon: nil
        )

        let action = ActitoInternals.PushAPI.Models.Notification.Action(
            type: "testType",
            label: "testLabel",
            target: nil,
            keyboard: nil,
            camera: nil,
            destructive: nil,
            icon: nil
        ).toModel()

        #expect(expectedAction == action)
    }

    @Test
    internal func testActionWithNilLabelToModel() {
        let action = ActitoInternals.PushAPI.Models.Notification.Action(
            type: "testType",
            label: nil,
            target: "testTarget",
            keyboard: true,
            camera: true,
            destructive: true,
            icon: ActitoNotification.Action.Icon(
                android: "testAndroid",
                ios: "testIos",
                web: "testWeb"
            )
        ).toModel()

        #expect(action == nil)
    }
}
