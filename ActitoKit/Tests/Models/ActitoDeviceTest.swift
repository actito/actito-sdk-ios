//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

internal struct ActitoDeviceTest {
    @Test
    internal func testActitoDeviceSerialization() {
        do {
            let device = ActitoDevice(
                id: "testId",
                userId: "testUserId",
                userName: "testUserName",
                timeZoneOffset: 0,
                dnd: ActitoDoNotDisturb(
                    start: try ActitoTime(hours: 21, minutes: 30),
                    end: try ActitoTime(hours: 8, minutes: 0)
                ),
                userData: ["testKey": "testValue"],
                backgroundAppRefresh: true
            )

            let convertedDevice = try ActitoDevice.fromJson(json: device.toJson())

            #expect(device == convertedDevice)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoDeviceSerializationWithNilProps() {
        let device = ActitoDevice(
            id: "testId",
            userId: nil,
            userName: nil,
            timeZoneOffset: 0,
            dnd: nil,
            userData: [:],
            backgroundAppRefresh: true
        )

        do {
            let convertedDevice = try ActitoDevice.fromJson(json: device.toJson())

            #expect(device == convertedDevice)
        } catch {
            Issue.record()
        }
    }
}
