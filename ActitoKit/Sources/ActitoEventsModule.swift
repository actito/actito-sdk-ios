//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

@MainActor
public protocol ActitoEventsModule: AnyObject {
    // func logApplicationException(_ error: Error, _ completion: @escaping ActitoCallback<Void>)

    /// Logs in Actito when a notification has been opened by the user, with a callback.
    ///
    /// This function logs in Actito the opening of a notification, enabling insight into user engagement with
    /// specific notifications.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the opened notification.
    ///   - completion: A callback that will be invoked with the result of the log notification open operation.
    func logNotificationOpen(_ id: String, _ completion: @escaping ActitoCallback<Void>)

    /// Logs in Actito when a notification has been opened by the user.
    ///
    /// This function logs in Actito the opening of a notification, enabling insight into user engagement with
    /// specific notifications.
    ///
    /// - Parameter id: The unique identifier of the opened notification.
    func logNotificationOpen(_ id: String) async throws

    /// Logs in Actito a custom event in the application, with a callback.
    ///
    /// This function allows logging, in Actito, of application-specific events, optionally associating structured
    /// data for more detailed event tracking and analysis.
    ///
    /// - Parameters:
    ///   - event: The name of the custom event to log.
    ///   - data: Optional structured event data for further details.
    ///   - completion: A callback that will be invoke with the result of the log custom operation.
    func logCustom(_ event: String, data: ActitoEventData?, _ completion: @escaping ActitoCallback<Void>)

    /// Logs in Actito a custom event in the application.
    ///
    /// This function allows logging, in Actito, of application-specific events, optionally associating structured
    /// data for more detailed event tracking and analysis.
    ///
    /// - Parameters:
    ///   - event: The name of the custom event to log.
    ///   - data: Optional structured event data for further details.
    func logCustom(_ event: String, data: ActitoEventData?) async throws
}

extension ActitoEventsModule {
    /// Logs in Actito a custom event in the application, with a callback.
    ///
    /// This function allows logging, in Actito, of application-specific events, optionally associating structured
    /// data for more detailed event tracking and analysis.
    ///
    /// - Parameters:
    ///   - event: The name of the custom event to log.
    ///   - data: Optional structured event data for further details.
    ///   - completion: A callback that will be invoke with the result of the log custom operation.
    public func logCustom(_ event: String, data: ActitoEventData? = nil, _ completion: @escaping ActitoCallback<Void>) {
        logCustom(event, data: data, completion)
    }

    /// Logs in Actito a custom event in the application.
    ///
    /// This function allows logging, in Actito, of application-specific events, optionally associating structured
    /// data for more detailed event tracking and analysis.
    ///
    /// - Parameters:
    ///   - event: The name of the custom event to log.
    ///   - data: Optional structured event data for further details.
    public func logCustom(_ event: String, data: ActitoEventData? = nil) async throws {
        try await logCustom(event, data: data)
    }
}

@MainActor
public protocol ActitoInternalEventsModule {
    func log(_ event: String, data: ActitoEventData?, sessionId: String?, notificationId: String?) async throws
}

extension ActitoInternalEventsModule {
    public func log(_ event: String, data: ActitoEventData? = nil, sessionId: String? = nil, notificationId: String? = nil) async throws {
        try await log(event, data: data, sessionId: sessionId, notificationId: notificationId)
    }
}
