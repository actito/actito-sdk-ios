//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension ActitoEventsComponent {
    internal func logRegionSession(_ session: ActitoInternals.PushAPI.Payloads.RegionSession) async throws {
        let sessionEnd = session.end ?? Date()
        let length = sessionEnd.timeIntervalSince(session.start)

        let data: ActitoEventData = [
            "region": session.regionId,
            "start": session.start,
            "end": sessionEnd,
            "length": length,
            "locations": session.locations.map { location -> [String: any Sendable] in
                var result: [String: any Sendable] = [
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "altitude": location.altitude,
                    "course": location.course,
                    "speed": location.speed,
                    "horizontalAccuracy": location.horizontalAccuracy,
                    "verticalAccuracy": location.verticalAccuracy,
                    "timestamp": location.timestamp,
                ]

                if let floor = location.floor {
                    result["floor"] = floor
                }

                return result
            },
        ]

        let this = self as! ActitoInternalEventsComponent
        try await this.log("re.notifica.event.region.Session", data: data)
    }

    internal func logBeaconSession(_ session: ActitoBeaconSession) async throws {
        let sessionEnd = session.end ?? Date()
        let length = sessionEnd.timeIntervalSince(session.start)

        let data: ActitoEventData = [
            "fence": session.regionId,
            "start": session.start,
            "end": sessionEnd,
            "length": length,
            "beacons": session.beacons.map { beacon -> [String: any Sendable] in
                var result: [String: any Sendable] = [
                    "proximity": beacon.proximity,
                    "major": beacon.major,
                    "minor": beacon.minor,
                    "timestamp": beacon.timestamp,
                ]

                if let location = beacon.location {
                    result["location"] = [
                        "latitude": location.latitude,
                        "longitude": location.longitude,
                    ]
                }

                return result
            },
        ]

        let this = self as! ActitoInternalEventsComponent
        try await this.log("re.notifica.event.beacon.Session", data: data)
    }

    internal func logVisit(_ visit: ActitoVisit) async throws {
        let data: ActitoEventData = [
            "departureDate": visit.departureDate,
            "arrivalDate": visit.arrivalDate,
            "latitude": visit.latitude,
            "longitude": visit.longitude,
        ]

        let this = self as! ActitoInternalEventsComponent
        try await this.log("re.notifica.event.location.Visit", data: data)
    }
}
