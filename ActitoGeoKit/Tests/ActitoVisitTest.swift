//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoGeoKit
import Testing

internal struct ActitoVisitTest {
    @Test
    internal func testActitoVisitSerialization() {
        let visit = ActitoVisit(
            departureDate: Date(timeIntervalSince1970: 1),
            arrivalDate: Date(timeIntervalSince1970: 2),
            latitude: 1.5,
            longitude: 1.5
        )
        
        do {
            let convertedVisit = try ActitoVisit.fromJson(json: visit.toJson())

            #expect(visit == convertedVisit)
        } catch {
            Issue.record()
        }
    }
}
