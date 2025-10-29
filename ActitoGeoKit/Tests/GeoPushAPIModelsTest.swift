//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoGeoKit
@testable import ActitoKit
import Testing

internal struct GeoPushAPIModelsTest {
    @Test
    internal func testActitoRegionToModel() {
        let expectedRegion = ActitoRegion(
            id: "testId",
            name: "testName",
            description: "testDescription",
            referenceKey: "testReferenceKey",
            geometry: ActitoRegion.Geometry(
                type: "testType",
                coordinate: ActitoRegion.Coordinate(
                    latitude: 0.5,
                    longitude: 1.5
                )
            ),
            advancedGeometry: ActitoRegion.AdvancedGeometry(
                type: "testType",
                coordinates: [
                    ActitoRegion.Coordinate(
                        latitude: 2.5,
                        longitude: 3.5
                    ),
                ]
            ),
            major: 1,
            distance: 4.5,
            timeZone: "testTimeZone",
            timeZoneOffset: 0
        )

        let region = ActitoInternals.PushAPI.Models.Region(
            _id: "testId",
            name: "testName",
            description: "testDescription",
            referenceKey: "testReferenceKey",
            geometry: ActitoInternals.PushAPI.Models.Region.Geometry(
                type: "testType",
                coordinates: [1.5, 0.5]
            ),
            advancedGeometry: ActitoInternals.PushAPI.Models.Region.AdvancedGeometry(
                type: "testType",
                coordinates: [[[3.5, 2.5]]]
            ),
            major: 1,
            distance: 4.5,
            timezone: "testTimeZone",
            timeZoneOffset: 0
        ).toModel()

        #expect(expectedRegion == region)
    }

    @Test
    internal func testActitoRegionWithNilPropsToModel() {
        let expectedRegion = ActitoRegion(
            id: "testId",
            name: "testName",
            description: nil,
            referenceKey: nil,
            geometry: ActitoRegion.Geometry(
                type: "testType",
                coordinate: ActitoRegion.Coordinate(
                    latitude: 0.5,
                    longitude: 1.5
                )
            ),
            advancedGeometry: nil,
            major: nil,
            distance: 2.5,
            timeZone: "testTimeZone",
            timeZoneOffset: 0
        )

        let region = ActitoInternals.PushAPI.Models.Region(
            _id: "testId",
            name: "testName",
            description: nil,
            referenceKey: nil,
            geometry: ActitoInternals.PushAPI.Models.Region.Geometry(
                type: "testType",
                coordinates: [1.5, 0.5]
            ),
            advancedGeometry: nil,
            major: nil,
            distance: 2.5,
            timezone: "testTimeZone",
            timeZoneOffset: 0
        ).toModel()

        #expect(expectedRegion == region)
    }
}
