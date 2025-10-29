//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoGeoKit
import Testing

internal struct ActitoRegionTest {
    @Test
    internal func testActitoRegionSerialization() {
        let region = ActitoRegion(
            id: "testId",
            name: "testName",
            description: "testDescription",
            referenceKey: "testReferenceKey",
            geometry: ActitoRegion.Geometry(
                type: "testType",
                coordinate: ActitoRegion.Coordinate(
                    latitude: 1.5,
                    longitude: 2.5
                )
            ),
            advancedGeometry: ActitoRegion.AdvancedGeometry(
                type: "testType",
                coordinates: [
                    ActitoRegion.Coordinate(
                        latitude: 3.5,
                        longitude: 4.5
                    ),
                ]
            ),
            major: 1,
            distance: 5.5,
            timeZone: "testTimeZone",
            timeZoneOffset: 0
        )

        do {
            let convertedRegion = try ActitoRegion.fromJson(json: region.toJson())

            #expect(region == convertedRegion)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoRegionSerializationWithNilProps() {
        let region = ActitoRegion(
            id: "testId",
            name: "testName",
            description: nil,
            referenceKey: nil,
            geometry: ActitoRegion.Geometry(
                type: "testType",
                coordinate: ActitoRegion.Coordinate(
                    latitude: 1.5,
                    longitude: 2.5
                )
            ),
            advancedGeometry: nil,
            major: nil,
            distance: 3.5,
            timeZone: "testTimeZone",
            timeZoneOffset: 0
        )

        do {
            let convertedRegion = try ActitoRegion.fromJson(json: region.toJson())

            #expect(region == convertedRegion)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testGeometrySerialization() {
        let geometry = ActitoRegion.Geometry(
            type: "testType",
            coordinate: ActitoRegion.Coordinate(
                latitude: 1.5,
                longitude: 2.5
            )
        )

        do {
            let convertedGeometry = try ActitoRegion.Geometry.fromJson(json: geometry.toJson())

            #expect(geometry == convertedGeometry)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testAdvancedGeometrySerialization() {
        let advancedGeometry = ActitoRegion.AdvancedGeometry(
            type: "testType",
            coordinates: [
                ActitoRegion.Coordinate(
                    latitude: 1.5,
                    longitude: 2.5
                ),
            ]
        )

        do {
            let convertedAdvancedGeometry = try ActitoRegion.AdvancedGeometry.fromJson(json: advancedGeometry.toJson())

            #expect(advancedGeometry == convertedAdvancedGeometry)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testAdvancedGeometryWithEmptyPropsSerialization() {
        let advancedGeometry = ActitoRegion.AdvancedGeometry(
            type: "testType",
            coordinates: []
        )

        do {
            let convertedAdvancedGeometry = try ActitoRegion.AdvancedGeometry.fromJson(json: advancedGeometry.toJson())

            #expect(advancedGeometry == convertedAdvancedGeometry)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testCoordinateSerialization() {
        let coordinate = ActitoRegion.Coordinate(
            latitude: 1.5,
            longitude: 2.5
        )

        do {
            let convertedCoordinate = try ActitoRegion.Coordinate.fromJson(json: coordinate.toJson())

            #expect(coordinate == convertedCoordinate)
        } catch {
            Issue.record()
        }
    }
}
