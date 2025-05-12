//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoGeoKit
import Testing

internal struct ActitoBeaconTest {
    @Test
    internal func testActitoBeaconSerialization() {
        let beacon = ActitoBeacon(
            id: "testId",
            name: "testName",
            major: 1,
            minor: 1,
            triggers: true,
            proximity: .unknown
        )

        do {
            let convertedBeacon = try ActitoBeacon.fromJson(json: beacon.toJson())

            #expect(beacon == convertedBeacon)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoBeaconWithNilPropsSerialization() {
        let beacon = ActitoBeacon(
            id: "testId",
            name: "testName",
            major: 1,
            minor: nil,
            triggers: true,
            proximity: .unknown
        )

        do {
            let convertedBeacon = try ActitoBeacon.fromJson(json: beacon.toJson())

            #expect(beacon == convertedBeacon)
        } catch {
            Issue.record()
        }
    }
}
