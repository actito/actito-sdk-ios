//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

public protocol ActitoModule {
    associatedtype Instance: ActitoModule

    static var instance: Instance { get }

    func migrate()

    func configure()

    func clearStorage() async throws

    func launch() async throws

    func postLaunch() async throws

    func unlaunch() async throws
}

extension ActitoModule {
    public func migrate() {}

    public func configure() {}

    public func clearStorage() async throws {}

    public func launch() async throws {}

    public func postLaunch() async throws {}

    public func unlaunch() async throws {}
}
