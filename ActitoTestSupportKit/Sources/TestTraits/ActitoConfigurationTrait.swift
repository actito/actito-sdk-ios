//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import Testing

@MainActor
public struct ActitoConfigurationTrait: SuiteTrait, TestTrait, TestScoping {
    public enum Workflow: Sendable {
        case configurationOnly
        case launch
    }

    public enum ExecutionMode: Sendable {
        case perSuite
        case perTest
    }

    nonisolated public let workflow: Workflow
    nonisolated public let mode: ExecutionMode

    nonisolated public var isRecursive: Bool {
        mode == .perTest
    }

    private static var isConfigured = false

    public init(workflow: Workflow, mode: ExecutionMode) {
        self.workflow = workflow
        self.mode = mode
    }

    public func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @concurrent @Sendable () async throws -> Void
    ) async throws {
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
        guard
            let path = Bundle(identifier: "com.actito.ActitoTestSupportKit")?
                .path(forResource: "TestActitoServices", ofType: "plist")
        else {
            fatalError("TestActitoServices.plist is missing.")
        }

        guard let servicesInfo = ActitoServicesInfo(contentsOfFile: path) else {
            fatalError("Could not parse the TestActitoServices plist. Please check the contents are valid.")
        }

        return servicesInfo
    }
}
