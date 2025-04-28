//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

internal struct ActitoDoNotDisturbTest {
    @Test
    internal func testActitoDoNotDisturbSerialization() {
        do {
            let dnd = ActitoDoNotDisturb(
                start: try ActitoTime(hours: 21, minutes: 30),
                end: try ActitoTime(hours: 08, minutes: 00)
            )

            let convertedDnd = try ActitoDoNotDisturb.fromJson(json: dnd.toJson())

            #expect(dnd == convertedDnd)
        } catch {
            Issue.record()
        }
    }
}
