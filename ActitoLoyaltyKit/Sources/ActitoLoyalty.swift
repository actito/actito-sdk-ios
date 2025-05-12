//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation
import PassKit
import UIKit

public protocol ActitoLoyalty: AnyObject {
    // MARK: Methods

    /// Presents a pass to the user in the given view controller.
    ///
    /// - Parameters:
    ///   - pass: The ``ActitoPass`` to be presented to the user.
    ///   - controller: The ``UIViewController`` in which to present the pass.
    func present(pass: ActitoPass, in controller: UIViewController)

    /// Fetches a pass by its serial number, with a callback.
    ///
    /// - Parameters:
    ///   - serial: The serial number of the pass to be fetched.
    ///   - completion: A callback that will be invoked with the result of the fetch operation.
    func fetchPass(serial: String, _ completion: @escaping ActitoCallback<ActitoPass>)

    /// Fetches a pass by its serial number.
    ///
    /// - Parameters:
    ///   - serial: The serial number of the pass to be fetched.
    ///
    /// - Returns: The fetched ``ActitoPass`` corresponding to the given serial number.
    func fetchPass(serial: String) async throws -> ActitoPass

    /// Fetches a pass by its barcode, with a callback.
    ///
    /// - Parameters:
    ///   - barcode: The barcode of the pass to be fetched.
    ///   - completion: A callback that will be invoked with the result of the fetch operation.
    func fetchPass(barcode: String, _ completion: @escaping ActitoCallback<ActitoPass>)

    /// Fetches a pass by its barcode.
    ///
    /// - Parameters:
    ///   - barcode: The barcode of the pass to be fetched.
    ///
    /// - Returns: The fetched ``ActitoPass`` corresponding to the given barcode.
    func fetchPass(barcode: String) async throws -> ActitoPass
}
