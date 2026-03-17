//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import ActitoTestSupportKit
import Testing

@MainActor
@Suite(.serialized, ActitoConfigurationTrait(workflow: .launch, mode: .perTest))
internal struct ActitoDeviceTagsTest {
    private let sampleTags = ["android", "testing", "remove-me"]
    private let sampleTagToRemove = "remove-me"

    @Test("test invalid formats")
    internal func testInvalidFormats() async {
        let invalidTags = [
            "te",
            "test.",
            "test&",
            ".test&",
            "test_test_test_test_test_test_test_test_test_test_test_test_test_test",
        ]

        for tag in invalidTags {
            await #expect(throws: ActitoError.self) {
                try await Actito.shared.device().addTag(tag)
            }
        }
    }

    @Test("ensure initially tags are empty")
    internal func ensureInitiallyTagsAreEmpty() async throws {
        let currentTags = try await Actito.shared.device().fetchTags()

        #expect(currentTags.isEmpty)
    }

    @Test("add tags")
    internal func addTags() async throws {
        try await Actito.shared.device().addTags(sampleTags)

        let tags = try await Actito.shared.device().fetchTags()

        #expect(tags.count == sampleTags.count)
        #expect(sampleTags.allSatisfy { tags.contains($0) })
        // #expect(tags.contains(sampleTags))
    }

    @Test("remove one tag")
    internal func removeOneTag() async throws {
        try await Actito.shared.device().addTags(sampleTags)
        try await Actito.shared.device().removeTag(sampleTagToRemove)

        let tags = try await Actito.shared.device().fetchTags()
        let expectedTags = sampleTags.filter { $0 != sampleTagToRemove }

        #expect(sampleTags.count > tags.count)
        #expect(expectedTags.allSatisfy { tags.contains($0) })

        // #expect(tags.contains(expectedTags))
        #expect(!tags.contains(sampleTagToRemove))
    }

    @Test("clear tags")
    internal func clearTags() async throws {
        try await Actito.shared.device().addTags(sampleTags)
        try await Actito.shared.device().clearTags()

        let tags = try await Actito.shared.device().fetchTags()

        #expect(tags.isEmpty)
    }
}
