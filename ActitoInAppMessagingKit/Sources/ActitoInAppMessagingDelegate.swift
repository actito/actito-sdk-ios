//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

public protocol ActitoInAppMessagingDelegate: AnyObject {
    /// Called when an in-app message is successfully presented to the user.
    ///
    /// - Parameters:
    ///   - actito: The ActitoInAppMessaging object instance.
    ///   - message: The ``ActitoInAppMessage`` that was presented.
    func actito(_ actito: ActitoInAppMessaging, didPresentMessage message: ActitoInAppMessage)

    /// Called when the presentation of an in-app message has finished.
    ///
    /// - Parameters:
    ///   - actito: The ActitoInAppMessaging object instance.
    ///   - message: The ``ActitoInAppMessage` that finished presenting.
    func actito(_ actito: ActitoInAppMessaging, didFinishPresentingMessage message: ActitoInAppMessage)

    /// Called when an in-app message failed to present.
    ///
    /// - Parameters:
    ///   - actito: The ActitoInAppMessaging object instance.
    ///   - message: The ``ActitoInAppMessage` that failed to be presented.
    func actito(_ actito: ActitoInAppMessaging, didFailToPresentMessage message: ActitoInAppMessage)

    /// Called when an action is successfully executed for an in-app message.
    ///
    /// - Parameters:
    ///   - actito: The ActitoInAppMessaging object instance.
    ///   - action: The ``ActitoInAppMessage` for which the action was executed.
    ///   - message: The ``ActitoInAppMessage.Action`` that was executed.
    func actito(_ actito: ActitoInAppMessaging, didExecuteAction action: ActitoInAppMessage.Action, for message: ActitoInAppMessage)

    /// Called when an action execution failed for an in-app message.
    ///
    /// - Parameters:
    ///   - actito: The ActitoInAppMessaging object instance.
    ///   - action: The ``ActitoInAppMessage.Action`` that failed to execute.
    ///   - message: The ``ActitoInAppMessage`` for which the action was attempted.
    ///   - error: An optional ``Error`` describing the error, or `nil` if no specific error was provided.
    func actito(_ actito: ActitoInAppMessaging, didFailToExecuteAction action: ActitoInAppMessage.Action, for message: ActitoInAppMessage, error: Error?)
}

extension ActitoInAppMessagingDelegate {
    public func actito(_: ActitoInAppMessaging, didPresentMessage _: ActitoInAppMessage) {}

    public func actito(_: ActitoInAppMessaging, didFinishPresentingMessage _: ActitoInAppMessage) {}

    public func actito(_: ActitoInAppMessaging, didFailToPresentMessage _: ActitoInAppMessage) {}

    public func actito(_: ActitoInAppMessaging, didExecuteAction _: ActitoInAppMessage.Action, for _: ActitoInAppMessage) {}

    public func actito(_: ActitoInAppMessaging, didFailToExecuteAction _: ActitoInAppMessage.Action, for _: ActitoInAppMessage, error _: Error?) {}
}
