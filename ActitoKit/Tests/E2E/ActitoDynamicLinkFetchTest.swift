//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import ActitoTestSupportKit
import Testing

private let TEST_DYNAMIC_LINK = "https://actito-sample-app-dev.test.ntc.re/0z4juv8466"
private let TEST_INVALID_DYNAMIC_LINK = "https://test.com/path"
private let TEST_DEEP_LINK = "com.actito.sample.app.test.dev://actito.com/example"

@MainActor
@Suite(ActitoConfigurationTrait(workflow: .configurationOnly, mode: .perSuite))
internal struct ActitoDynamicLinkFetchTest {
    @Test("dynamic link handle empty url")
    internal func dynamicLinkHandleEmptyUrl() {
        let url = URL(string: "https://")!

        let didHandle = Actito.shared.handleDynamicLinkUrl(url)

        #expect(didHandle == false)
    }

    @Test("dynamic link handle wrong host")
    internal func dynamicLinkHandleWrongHost() {
        let url = URL(string: TEST_INVALID_DYNAMIC_LINK)!

        let didHandle = Actito.shared.handleDynamicLinkUrl(url)

        #expect(didHandle == false)
    }

    @Test("dynamic link handle valid link")
    internal func dynamicLinkHandleValidLink() {
        let url = URL(string: TEST_DYNAMIC_LINK)!

        let didHandle = Actito.shared.handleDynamicLinkUrl(url)

        #expect(didHandle == true)
    }

    @Test("dynamic link fetch invalid link")
    internal func dynamicLinkFetchInvalidLink() async {
        let url = URL(string: TEST_INVALID_DYNAMIC_LINK)!

        await #expect(throws: ActitoNetworkError.self) {
            try await Actito.shared.fetchDynamicLink(url.absoluteString)
        }
    }

    @Test("dynamic link fetch valid link")
    internal func dynamicLinkFetchValidLink() async throws {
        let url = URL(string: TEST_DYNAMIC_LINK)!

        let dynamicLink = try await Actito.shared.fetchDynamicLink(url.absoluteString)

        #expect(dynamicLink.target == TEST_DEEP_LINK)
    }
}
