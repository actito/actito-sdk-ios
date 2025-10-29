//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoGeoKit
import CoreLocation
import Testing

internal struct ActitoLocationTest {
    @Test
    internal func testActitoLocationCLLocationInitialization() {
        let expectedLocation = ActitoLocation(
            latitude: 0.5,
            longitude: 1.5,
            altitude: 2.5,
            course: 3.5,
            speed: 4.5,
            floor: nil,
            horizontalAccuracy: 5.5,
            verticalAccuracy: 6.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        let clLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: 0.5,
                longitude: 1.5
            ),
            altitude: 2.5,
            horizontalAccuracy: 5.5,
            verticalAccuracy: 6.5,
            course: 3.5,
            speed: 4.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        let location = ActitoLocation(cl: clLocation)

        #expect(expectedLocation == location)
    }

    @Test
    internal func testActitoLocationSerialization() {
        let location = ActitoLocation(
            latitude: 0.5,
            longitude: 1.5,
            altitude: 2.5,
            course: 3.5,
            speed: 4.5,
            floor: 0,
            horizontalAccuracy: 5.5,
            verticalAccuracy: 6.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedLocation = try ActitoLocation.fromJson(json: location.toJson())

            #expect(location == convertedLocation)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoLocationSerializationWithNilProps() {
        let location = ActitoLocation(
            latitude: 0.5,
            longitude: 1.5,
            altitude: 2.5,
            course: 3.5,
            speed: 4.5,
            floor: nil,
            horizontalAccuracy: 5.5,
            verticalAccuracy: 6.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedLocation = try ActitoLocation.fromJson(json: location.toJson())

            #expect(location == convertedLocation)
        } catch {
            Issue.record()
        }
    }
}
