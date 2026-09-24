//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoGeoKit
import SwiftUI

internal struct BeaconRow: View {
    internal let region: ActitoRegion
    internal let beacon: ActitoBeacon

    internal var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(beacon.name)
                .font(.title3.weight(.medium))

            Spacer()

            HStack {
                Spacer()
                ChipView(text: String(localized: "beacons_beacon_major", beacon.major))
                Spacer()
                ChipView(text: String(localized: "beacons_beacon_minor", beacon.minor ?? "nil"))
                Spacer()
                ChipView(text: String(localized: "beacons_beacon_proximity", beacon.proximity.rawValue))
                Spacer()
            }

            Spacer()

            HStack {
                Text(String(localized: "beacons_beacon_region_name"))

                Spacer()

                Text(String(region.name))
            }

            HStack {
                Text(String(localized: "beacons_beacon_triggers"))

                Spacer()

                Text(String(beacon.triggers))
            }

            HStack {
                Text(String(localized: "beacons_beacon_id"))

                Spacer()

                Text(String(beacon.id))
            }
        }
    }
}

internal struct BeaconRow_Previews: PreviewProvider {
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
            advancedGeometry: nil,
            major: 10000,
            distance: 10000.1,
            timeZone: "Europe/Lisbon",
            timeZoneOffset: 1.0
        )

        let beacon = ActitoBeacon(
            id: UUID().uuidString,
            name: "Test beacon",
            major: 1,
            minor: 100,
            triggers: true,
            proximity: .immediate
        )

        BeaconRow(region: region, beacon: beacon)
    }
}
