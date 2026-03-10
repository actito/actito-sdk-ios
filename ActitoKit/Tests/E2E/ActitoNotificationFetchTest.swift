//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

@Suite(ActitoConfigurationTrait(workflow: .launch, mode: .perSuite))
internal struct ActitoNotificationFetchTest {

    @Test("notification fetch")
    internal func fetchNotification() async throws {
        let notification = try await Actito.shared.fetchNotification("699706530ba8bedd427d3b15")

        #expect(notification.title == "Test title")
        #expect(notification.subtitle == "Test subtitle")
        #expect(notification.message == "Test message")
    }
}
