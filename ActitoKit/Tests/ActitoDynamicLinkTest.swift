//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

internal struct ActitoDynamicLinkTest {
    @Test
    internal func testActitoDynamicLinkSerialization() {
        let link = ActitoDynamicLink(target: "testLink")

        do {
            let convertedLink = try ActitoDynamicLink.fromJson(json: link.toJson())

            #expect(link == convertedLink)
        } catch {
            Issue.record()
        }
    }
}
