//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoGeoKit
import Testing

internal struct ActitoHeadingTest {
    @Test
    internal func testActitoHeadingSerialization() {
        let heading = ActitoHeading(
            magneticHeading: 0.5,
            trueHeading: 1.5,
            headingAccuracy: 2.5,
            x: 3.5,
            y: 4.5,
            z: 5.5,
            timestamp: Date(timeIntervalSince1970: 1)
        )

        do {
            let convertedHeading = try ActitoHeading.fromJson(json: heading.toJson())

            #expect(heading == convertedHeading)
        } catch {
            Issue.record()
        }
    }
}
