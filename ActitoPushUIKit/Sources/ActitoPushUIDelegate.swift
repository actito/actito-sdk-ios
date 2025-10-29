//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit

@MainActor
public protocol ActitoPushUIDelegate: AnyObject {
    // MARK: - Notifications

    /// Called when a notification is about to be presented.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - notification: The ``ActitoNotification`` that will be presented.
    func actito(_ actitoPushUI: ActitoPushUI, willPresentNotification notification: ActitoNotification)

    /// Called when a notification has been presented.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - notification: The ``ActitoNotification`` that was presented.
    func actito(_ actitoPushUI: ActitoPushUI, didPresentNotification notification: ActitoNotification)

    /// Called when the presentation of a notification has finished.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - notification: The ``ActitoNotification`` that finished presenting.
    func actito(_ actitoPushUI: ActitoPushUI, didFinishPresentingNotification notification: ActitoNotification)

    /// Called when a notification fails to present.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - notification: The ``ActitoNotification` that failed to present.
    func actito(_ actitoPushUI: ActitoPushUI, didFailToPresentNotification notification: ActitoNotification)

    /// Called when a URL within a notification is clicked.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - url: The clicked URL.
    ///   - notification: The ``ActitoNotification`` containing the clicked URL.
    func actito(_ actitoPushUI: ActitoPushUI, didClickURL url: URL, in notification: ActitoNotification)

    // MARK: - Actions

    /// Called when an action associated with a notification is about to execute.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - action: The ``ActitoNotification.Action`` that will be executed.
    ///   - notification: The ``ActitoNotification`` containing the action.
    func actito(_ actitoPushUI: ActitoPushUI, willExecuteAction action: ActitoNotification.Action, for notification: ActitoNotification)

    /// Called when an action associated with a notification has been executed.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - action: The ``ActitoNotification.Action`` that was executed.
    ///   - notification: The ``ActitoNotification`` containing the action.
    func actito(_ actitoPushUI: ActitoPushUI, didExecuteAction action: ActitoNotification.Action, for notification: ActitoNotification)

    /// Called when an action associated with a notification is available but has not been executed by the user.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - action: The ``ActitoNotification.Action`` that was not executed.
    ///   - notification: The ``ActitoNotification`` containing the action.
    func actito(_ actitoPushUI: ActitoPushUI, didNotExecuteAction action: ActitoNotification.Action, for notification: ActitoNotification)

    /// Called when an action associated with a notification fails to execute.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - action: The ``ActitoNotification.Action` that failed to execute.
    ///   - notification: The ``ActitoNotification`` containing the action.
    ///   - error: The ``Error`` associated with the failure (optional).
    func actito(_ actitoPushUI: ActitoPushUI, didFailToExecuteAction action: ActitoNotification.Action, for notification: ActitoNotification, error: Error?)

    /// Called when a custom action associated with a notification is received.
    ///
    /// - Parameters:
    ///   - actitoPushUI: The ActitoPushUI object instance.
    ///   - url: The URL representing the custom action.
    ///   - action: The ``ActitoNotification.Action`` that triggered the custom action.
    ///   - notification: The `ActitoNotification`` containing the custom action.
    func actito(_ actitoPushUI: ActitoPushUI, didReceiveCustomAction url: URL, in action: ActitoNotification.Action, for notification: ActitoNotification)
}

extension ActitoPushUIDelegate {
    public func actito(_: ActitoPushUI, willPresentNotification _: ActitoNotification) {}

    public func actito(_: ActitoPushUI, didPresentNotification _: ActitoNotification) {}

    public func actito(_: ActitoPushUI, didFinishPresentingNotification _: ActitoNotification) {}

    public func actito(_: ActitoPushUI, didFailToPresentNotification _: ActitoNotification) {}

    public func actito(_: ActitoPushUI, didClickURL _: URL, in _: ActitoNotification) {}

    public func actito(_: ActitoPushUI, willExecuteAction _: ActitoNotification.Action, for _: ActitoNotification) {}

    public func actito(_: ActitoPushUI, didExecuteAction _: ActitoNotification.Action, for _: ActitoNotification) {}

    public func actito(_: ActitoPushUI, didNotExecuteAction _: ActitoNotification.Action, for _: ActitoNotification) {}

    public func actito(_: ActitoPushUI, didFailToExecuteAction _: ActitoNotification.Action, for _: ActitoNotification, error _: Error?) {}

    public func actito(_: ActitoPushUI, didReceiveCustomAction _: URL, in _: ActitoNotification.Action, for _: ActitoNotification) {}
}
