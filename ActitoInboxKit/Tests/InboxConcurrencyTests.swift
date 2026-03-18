//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UserNotifications
@testable import ActitoKit
@testable import ActitoInboxKit
import ActitoTestSupportKit
import Testing

@MainActor
@Suite(.serialized, ActitoConfigurationTrait(workflow: .launch, mode: .perSuite))
internal struct InboxConcurrencyTests {

    @Test
    internal func testMassiveRefreshOperations() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0...10 {
                group.addTask {
                    try await Actito.shared.inbox().refresh()
                }
            }
        }
    }

    @Test
    internal func testMassiveOpenOperations() async throws {
        Actito.shared.notificationCenter = MockNotificationCenter()
        Actito.shared.inbox().notificationCenter = MockNotificationCenter()

        try await Actito.shared.events().logCustom("test_massive_open_operation")

        while Actito.shared.inbox().items.isEmpty {
            try await Actito.shared.inbox().refresh()
        }

        let item = try #require(Actito.shared.inbox().items.first(where: { !$0.opened }))

        await withThrowingTaskGroup(of: ActitoNotification.self) { group in
            for _ in 0...10 {
                group.addTask {
                    try await Actito.shared.inbox().open(item)
                }
            }
        }

        let updatedItem = try #require(Actito.shared.inbox().items.first(where: { $0.id == item.id }))
        #expect(updatedItem.opened == true)
    }
}
