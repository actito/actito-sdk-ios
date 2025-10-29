//
// Copyright (c) 2025 Actito. All rights reserved.
//

@MainActor
public protocol ActitoLaunchComponent {
    associatedtype Instance: ActitoLaunchComponent

    static var instance: Instance { get }

    func migrate()

    func configure()

    func clearStorage() async throws

    func launch() async throws

    func postLaunch() async throws

    func unlaunch() async throws

    func executeCommand(_ command: String, data: Any?) throws -> (any Sendable)?
}
