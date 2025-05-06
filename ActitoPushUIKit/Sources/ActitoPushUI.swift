//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation
import UIKit

public protocol ActitoPushUI: AnyObject {
    // MARK: Properties

    /// Specifies the delegate that handles notification lifecycle events
    ///
    /// This property allows setting a delegate conforming to ``ActitoPushUIDelegate`` to respond to various notification lifecycle events,
    /// such as when a notification is presented, actions are executed, or errors occur.
    var delegate: ActitoPushUIDelegate? { get set }

    // MARK: Methods

    /// Presents a notification to the user.
    ///
    /// This method launches the UI for displaying the provided ``ActitoNotification`` on the provided ``UIViewController``.
    ///
    /// - Parameters:
    ///   - notification: The ``ActitoNotification`` to present.
    ///   - controller: The ``UIViewController`` in which to present the notification.
    func presentNotification(_ notification: ActitoNotification, in controller: UIViewController)

    /// Presents an action associated with a notification.
    ///
    /// This method presents the UI for executing a specific ``ActitoNotification.Action`` associated with the provided ``ActitoNotification``.
    ///
    /// - Parameters:
    ///   - action: The ``ActitoNotification.Action`` to execute.
    ///   - notification: The ``ActitoNotification`` to present.
    ///   - controller: The ``UIViewController`` in which to present the action.
    func presentAction(_ action: ActitoNotification.Action, for notification: ActitoNotification, in controller: UIViewController)
}
