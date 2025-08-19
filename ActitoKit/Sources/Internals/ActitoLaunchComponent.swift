//
// Copyright (c) 2025 Actito. All rights reserved.
//

public protocol ActitoLaunchComponent: Sendable {
    associatedtype Instance: ActitoLaunchComponent

    static var instance: Instance { get }

    func migrate()

    @MainActor
    func configure()

    func clearStorage() async throws

    func launch() async throws

    func postLaunch() async throws

    func unlaunch() async throws

    func executeCommand(_ command: String, data: Any?) async throws -> (any Sendable)?
}
