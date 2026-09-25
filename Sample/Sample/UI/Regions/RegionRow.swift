//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoGeoKit
import SwiftUI

internal struct RegionRow: View {
    internal let region: ActitoRegion

    private var geometryText: String {
        let g = region.geometry
        return "\(g.type)\nlat \(g.coordinate.latitude), long \(g.coordinate.longitude)"
    }

    private var advancedGeometryText: String {
        guard let advancedGeometry = region.advancedGeometry else {
            return "nil"
        }
        let coordinates = advancedGeometry.coordinates
            .map { "(\($0.latitude), \($0.longitude))" }
            .joined(separator: ", ")
        return "\(advancedGeometry.type): \(coordinates)"
    }

    internal var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: region.name)

            if let description = region.description {
                Text(verbatim: description)
                    .font(.caption)
            }

            Spacer()

            HStack {
                Spacer()
                ChipView(text: String(localized: "regions_region_distance", region.distance))
                Spacer()
                ChipView(text: String(localized: "regions_region_major", region.major ?? "nil"))
                Spacer()
            }

            Spacer()

            HStack {
                Text(String(localized: "regions_region_geometry"))

                Spacer()

                Text(String(geometryText))
            }

            HStack {
                Text(String(localized: "regions_region_advanced_geometry"))

                Spacer()

                Text(String(advancedGeometryText))
            }

            HStack {
                Text(String(localized: "regions_region_reference_key"))

                Spacer()

                Text(String(region.referenceKey ?? "nil"))
            }

            HStack {
                Text(String(localized: "regions_region_timezone"))

                Spacer()

                Text(String(region.timeZone))
            }

            HStack {
                Text(String(localized: "regions_region_timezone_offset"))

                Spacer()

                Text(String("\(region.timeZoneOffset)"))
            }

            HStack {
                Text(String(localized: "regions_region_id"))

                Spacer()

                Text(String(region.id ))
            }
        }
    }
}

internal struct RegionRow_Previews: PreviewProvider {
    internal static var previews: some View {
        let region = ActitoRegion(
            id: "id",
            name: "Region Name",
            description: "Region Description",
            referenceKey: "key",
            geometry: ActitoRegion.Geometry(
                type: "Point",
                coordinate: ActitoRegion.Coordinate(
                    latitude: 1000.1,
                    longitude: 1000.1
                )
            ),
            advancedGeometry: ActitoRegion.AdvancedGeometry(
                type: "Square",
                coordinates: [
                    ActitoRegion.Coordinate(
                        latitude: 1000.1,
                        longitude: 1000.1
                    ),
                    ActitoRegion.Coordinate(
                        latitude: 1000.1,
                        longitude: 1000.1
                    ),
                    ActitoRegion.Coordinate(
                        latitude: 1000.1,
                        longitude: 1000.1
                    ),
                    ActitoRegion.Coordinate(
                        latitude: 1000.1,
                        longitude: 1000.1
                    ),
                ]
            ),
            major: 10000,
            distance: 10000.1,
            timeZone: "Europe/Lisbon",
            timeZoneOffset: 1.0
        )

        RegionRow(region: region)
    }
}
