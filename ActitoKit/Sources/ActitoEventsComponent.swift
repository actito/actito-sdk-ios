//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import UIKit

public typealias ActitoEventData = [String: any Sendable]

private let MAX_RETRIES = 5
private let MAX_DATA_SIZE_BYTES = 2 * 1024
private let MIN_EVENT_NAME_SIZE_CHAR = 3
private let MAX_EVENT_NAME_SIZE_CHAR = 64
private let EVENT_NAME_REGEX = "^[a-zA-Z0-9]([a-zA-Z0-9_-]+[a-zA-Z0-9])?$".toRegex()
private let UPLOAD_TASK_NAME = "re.notifica.tasks.events.Upload"

@MainActor
public final class ActitoEventsComponent {
    internal static let instance = ActitoEventsComponent()

    private let discardableEvents = [String]()
    private var processEventsTaskIdentifier: UIBackgroundTaskIdentifier?

    // MARK: - Actito Events

    /// Logs in Actito when a notification has been opened by the user, with a callback.
    ///
    /// This function logs in Actito the opening of a notification, enabling insight into user engagement with
    /// specific notifications.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the opened notification.
    ///   - completion: A callback that will be invoked with the result of the log notification open operation.
    public func logNotificationOpen(_ id: String, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await logNotificationOpen(id)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Logs in Actito when a notification has been opened by the user.
    ///
    /// This function logs in Actito the opening of a notification, enabling insight into user engagement with
    /// specific notifications.
    ///
    /// - Parameter id: The unique identifier of the opened notification.
    public func logNotificationOpen(_ id: String) async throws {
        try await log("re.notifica.event.notification.Open", data: nil, notificationId: id)
    }

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
        Task {
            do {
                try await logCustom(event, data: data)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
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
        guard Actito.shared.isReady else {
            throw ActitoError.notReady
        }

        if Actito.shared.application?.enforceEventNameRestrictions == true {
            if event.count < MIN_EVENT_NAME_SIZE_CHAR || event.count > MAX_EVENT_NAME_SIZE_CHAR || !event.matches(EVENT_NAME_REGEX) {
                throw ActitoError.invalidArgument(
                    message: "Invalid event name '\(event)'. Event name must have between \(MIN_EVENT_NAME_SIZE_CHAR)-\(MAX_EVENT_NAME_SIZE_CHAR) characters and match this pattern: \(EVENT_NAME_REGEX.pattern)"
                )
            }
        }

        if
            Actito.shared.application?.enforceSizeLimit == true,
            let data = data
        {
            let serializedData = try JSONEncoder.actito.encode(ActitoAnyCodable(data))
            let size = serializedData.count

            if size > MAX_DATA_SIZE_BYTES {
                throw ActitoError.contentTooLarge(
                    message: "Data for event '\(event)' of size \(size)B exceeds max size of \(MAX_DATA_SIZE_BYTES)B"
                )
            }
        }

        try await log("re.notifica.event.custom.\(event)", data: data)
    }

    // MARK: - Actito Internal Events

    /// - Warning: For internal use only.
    public func log(_ event: String, data: ActitoEventData? = nil, sessionId: String? = nil, notificationId: String? = nil) async throws {
        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        let payload = ActitoInternals.PushAPI.Payloads.CreateEventPayload(
            type: event,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000),
            deviceId: device.id,
            sessionId: sessionId ?? Actito.shared.session().sessionId,
            notificationId: notificationId,
            userId: device.userId,
            data: data
        )

        try await log(payload)
    }

    // MARK: - Internal API

    internal func configure() {
        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to reachability changed events.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onReachabilityChanged(_:)),
            name: .reachabilityChanged,
            object: nil
        )
    }

    internal func launch() {
        processStoredEvents()
    }

    internal func logApplicationInstall() async throws {
        try await log("re.notifica.event.application.Install")
    }

    internal func logApplicationRegistration() async throws {
        try await log("re.notifica.event.application.Registration")
    }

    internal func logApplicationUpgrade() async throws {
        try await log("re.notifica.event.application.Upgrade")
    }

    internal func logApplicationOpen(sessionId: String) async throws {
        try await log("re.notifica.event.application.Open", sessionId: sessionId)
    }

    internal func logApplicationClose(sessionId: String, sessionLength: Double) async throws {
        try await log("re.notifica.event.application.Close", data: ["length": String(sessionLength)], sessionId: sessionId)
    }

    private func log(_ payload: ActitoInternals.PushAPI.Payloads.CreateEventPayload) async throws {
        guard Actito.shared.isConfigured else {
            logger.debug("Actito is not configured. Cannot log the event.")
            throw ActitoError.notConfigured
        }

        do {
            try await ActitoRequest.Builder()
                .post("/event", body: payload)
                .response()

            logger.info("Event '\(payload.type)' sent successfully.")
        } catch {
            logger.warning("Failed to send the event '\(payload.type)'.", error: error)

            if !discardableEvents.contains(payload.type), let error = error as? ActitoNetworkError, error.recoverable {
                logger.info("Queuing event to be sent whenever possible.")

                try await Actito.shared.database.add(payload.toLocal())
                processStoredEvents()

                return
            }

            throw error
        }
    }

    private func processStoredEvents() {
        // Check that Actito is ready to process the events.
        guard Actito.shared.state >= .configured else {
            logger.debug("Actito is not ready yet. Skipping...")
            return
        }

        // Ensure there is no running task.
        guard processEventsTaskIdentifier == nil else {
            logger.debug("There's an upload task running. Skipping...")
            return
        }

        // Notify the system about a long running task.
        self.processEventsTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: UPLOAD_TASK_NAME) {
            // Check the task is still running.
            guard let taskId = self.processEventsTaskIdentifier else {
                return
            }

            // Stop the task if the given time expires.
            logger.debug("Completing background task after its expiration.")
            UIApplication.shared.endBackgroundTask(taskId)
            self.processEventsTaskIdentifier = nil
        }

        // Run the task on a background queue.
        Task(priority: .background) {
            // Load and process the stored events.
            if let events = try? await Actito.shared.database.fetchEvents() {
                await self.process(events)
            }

            // Check the task is still running.
            guard let taskId = self.processEventsTaskIdentifier else {
                return
            }

            // Stop the task if the given time expires.
            logger.debug("Completing background task after processing all the events.")
            UIApplication.shared.endBackgroundTask(taskId)
            self.processEventsTaskIdentifier = nil
        }
    }

    private func process(_ events: [LocalEvent]) async {
        guard !events.isEmpty else {
            logger.debug("Nothing to process.")
            return
        }

        var eventsRemaining = events.count

        for event in events {
            guard processEventsTaskIdentifier != nil else {
                logger.debug("The background task was terminated before all the events could be processed.")
                return
            }

            logger.debug("\(eventsRemaining) events remaining. Processing...")
            await process(event)

            eventsRemaining -= 1
        }

        logger.debug("Finished processing all the events.")
    }

    private func process(_ localEvent: LocalEvent) async {
        let createdAt = Date(timeIntervalSince1970: Double(localEvent.timestamp / 1000))
        let expiresAt = createdAt.addingTimeInterval(Double(localEvent.ttl))
        let now = Date()

        if now > expiresAt {
            logger.debug("Event expired. Removing...")
            await Actito.shared.database.remove(localEvent)
            return
        }

        do {
            let payload = ActitoInternals.PushAPI.Payloads.CreateEventPayload(from: localEvent)

            try await ActitoRequest.Builder()
                .post("/event", body: payload)
                .response()

            logger.debug("Event processed. Removing from storage...")
            await Actito.shared.database.remove(localEvent)
        } catch {
            if let error = error as? ActitoNetworkError, error.recoverable {
                logger.debug("Failed to process event.")

                var updatedLocalEvent = localEvent

                // Increase the attempts counter.
                updatedLocalEvent.retries += 1

                if updatedLocalEvent.retries < MAX_RETRIES {
                    try? await Actito.shared.database.update(updatedLocalEvent)
                } else {
                    logger.debug("Event was retried too many times. Removing...")
                    await Actito.shared.database.remove(updatedLocalEvent)
                }
            } else {
                logger.debug("Failed to process event due to an unrecoverable error. Discarding it...")
                await Actito.shared.database.remove(localEvent)
            }
        }
    }

    @objc internal func onApplicationDidBecomeActiveNotification(_: Notification) {
        guard Actito.shared.isReady else { return }

        processStoredEvents()
    }

    @objc internal func onReachabilityChanged(_: Notification) {
        guard let reachability = Actito.shared.reachability else {
            logger.debug("Reachbility module not configure.")
            return
        }

        guard Actito.shared.isReady else { return }

        switch reachability.connection {
        case .unavailable:
            guard let taskId = processEventsTaskIdentifier else {
                return
            }

            // Stop the task if there is no connectivity.
            logger.debug("Stopping background task due to lack of connectivity.")
            UIApplication.shared.endBackgroundTask(taskId)
            processEventsTaskIdentifier = nil
        case .cellular, .wifi:
            logger.debug("Starting background task to upload stored events.")
            processStoredEvents()
        }
    }
}

// MARK: - Recoverable ActitoError

// swiftlint:disable:next no_extension_access_modifier
private extension ActitoNetworkError {
    var recoverable: Bool {
        switch self {
        case .genericError,
                .inaccessible,
                .urlError:
            return true
        default:
            return false
        }
    }
}
