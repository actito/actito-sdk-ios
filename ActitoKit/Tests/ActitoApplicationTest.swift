//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

internal struct ActitoApplicationTest {
    @Test
    internal func testActitoApplicationSerialization() {
        let application = ActitoApplication(
            id: "testString",
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
            ]
        )

        do {
            let convertedApplication = try ActitoApplication.fromJson(json: application.toJson())

            #expect(application == convertedApplication)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoApplicationSerializationWithNilProps() {
        let application = ActitoApplication(
            id: "testString",
            name: "testName",
            category: "testCategory",
            appStoreId: nil,
            services: [:],
            inboxConfig: nil,
            regionConfig: nil,
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
                    description: nil,
                    type: "testType",
                    actions: []
                ),
            ]
        )

        do {
            let convertedApplication = try ActitoApplication.fromJson(json: application.toJson())

            #expect(application == convertedApplication)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testInboxConfigSerialization() {
        let config = ActitoApplication.InboxConfig(
            useInbox: true,
            useUserInbox: true,
            autoBadge: true
        )

        do {
            let convertedConfig = try ActitoApplication.InboxConfig.fromJson(json: config.toJson())

            #expect(config == convertedConfig)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testRegionConfigSerialization() {
        let config = ActitoApplication.RegionConfig(proximityUUID: "testUUID")

        do {
            let convertedConfig = try ActitoApplication.RegionConfig.fromJson(json: config.toJson())

            #expect(config == convertedConfig)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testUserDataFieldSerialization() {
        let field = ActitoApplication.UserDataField(
            type: "testType",
            key: "testKey",
            label: "testLabel"
        )

        do {
            let convertedField = try ActitoApplication.UserDataField.fromJson(json: field.toJson())

            #expect(field == convertedField)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionCategorySerialization() {
        let category = ActitoApplication.ActionCategory(
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
        )

        do {
            let convertedCategory = try ActitoApplication.ActionCategory.fromJson(json: category.toJson())

            #expect(category == convertedCategory)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActionCategorySerializationWithNilProps() {
        let category = ActitoApplication.ActionCategory(
            name: "testName",
            description: nil,
            type: "testType",
            actions: []
        )

        do {
            let convertedCategory = try ActitoApplication.ActionCategory.fromJson(json: category.toJson())

            #expect(category == convertedCategory)
        } catch {
            Issue.record()
        }
    }
}
