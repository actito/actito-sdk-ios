//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

@MainActor
internal struct ActitoConfigurationTrait: SuiteTrait, TestTrait, TestScoping {
    internal enum Workflow {
        case configurationOnly
        case launch
    }

    internal enum ExecutionMode {
        case perSuite
        case perTest
    }

    internal let workflow: Workflow
    internal let mode: ExecutionMode

    nonisolated internal var isRecursive: Bool {
        mode == .perTest
    }

    private static var isConfigured = false

    internal func provideScope(for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void) async throws {
        try await beforeSuite()

        try await function()

        try await afterSuite()
    }

    internal func beforeSuite() async throws {
        guard !Self.isConfigured else { return }
        Self.isConfigured = true

        Actito.shared.configure(
            servicesInfo: loadActitoServices()
        )

        if workflow == .launch {
            try await Actito.shared.launch()
        }
    }

    internal func afterSuite() async throws {
        if workflow == .launch {
            try await Actito.shared.unlaunch()
        }

        Self.isConfigured = false
    }

    private func loadActitoServices() -> ActitoServicesInfo {
        guard let path = Bundle(identifier: "com.actito.CoreTests")?.path(forResource: "TestActitoServices", ofType: "plist") else {
            fatalError("TestActitoServices.plist is missing.")
        }

        guard let servicesInfo = ActitoServicesInfo(contentsOfFile: path) else {
            fatalError("Could not parse the TestActitoServices plist. Please check the contents are valid.")
        }

        return servicesInfo
    }
}
