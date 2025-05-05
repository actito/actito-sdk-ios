//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

public protocol ActitoAssets: AnyObject {
    /// Fetches a list of ``ActitoAsset`` for a specified group, with a callback.
    ///
    /// - Parameters:
    ///   - group: The name of the group whose assets are to be fetched.
    ///   - completion: A callback that will be invoked with the result of the fetch operation.
    func fetch(group: String, _ completion: @escaping ActitoCallback<[ActitoAsset]>)

    /// Fetches a list of ``ActitoAsset`` for a specified group.
    ///
    /// - Parameters:
    ///   - group: The name of the group whose assets are to be fetched.
    ///
    /// - Returns: A list of ``ActitoAsset`` belonging to a specified group.
    func fetch(group: String) async throws -> [ActitoAsset]
}
