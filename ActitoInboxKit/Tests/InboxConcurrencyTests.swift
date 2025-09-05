//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Testing
import ActitoKit
@testable import ActitoInboxKit

@MainActor
internal struct InboxConcurrencyTests {

    @Test
    internal func testMassiveRefreshOperations() async throws {
        try await setupActito()

        await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0...10 {
                group.addTask { @MainActor in
                    try await Actito.shared.inbox().refresh()
                }
            }
        }
    }

    @Test
    internal func testMassiveOpenOperations() async throws {
        try await setupActito()

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

    private func setupActito() async throws {
        Actito.shared.configure(
            servicesInfo: ActitoServicesInfo(
                applicationKey: "",
                applicationSecret: ""
            ),
            options: ActitoOptions(
                debugLoggingEnabled: true
            )
        )

        try await Actito.shared.launch()
    }
}
