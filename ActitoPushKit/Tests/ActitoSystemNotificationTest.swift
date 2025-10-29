//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoPushKit
import Testing

internal struct ActitoSystemNotificationTest {
    @Test
    internal func testActitoSystemNotificationSerialization() {
        let notification = ActitoSystemNotification(
            id: "testId",
            type: "testType",
            extra: ["testKey": "testValue"]
        )

        do {
            let convertedNotification = try ActitoSystemNotification.fromJson(json: notification.toJson())

            #expect(notification == convertedNotification)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoSystemNotificationSerializationWithNilProps() {
        let notification = ActitoSystemNotification(
            id: "testId",
            type: "testType",
            extra: [:]
        )

        do {
            let convertedNotification = try ActitoSystemNotification.fromJson(json: notification.toJson())

            #expect(notification == convertedNotification)
        } catch {
            Issue.record()
        }
    }
}
