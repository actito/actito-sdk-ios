//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit
import ActitoUtilitiesKit

private let MAX_RETRIES = 5
private let UPLOAD_TASK_NAME = "re.notifica.tasks.events.Upload"

internal class ActitoEventsModuleImpl: NSObject, ActitoModule, ActitoEventsModule, ActitoInternalEventsModule {
    private let discardableEvents = [String]()
    private var processEventsTaskIdentifier: UIBackgroundTaskIdentifier?

    // MARK: - Actito Module

    internal static let instance = ActitoEventsModuleImpl()

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

    internal func launch() async throws {
        processStoredEvents()
    }

    // MARK: - Actito Events

    internal func logNotificationOpen(_ id: String, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await logNotificationOpen(id)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    internal func logNotificationOpen(_ id: String) async throws {
        try await log("re.notifica.event.notification.Open", data: nil, notificationId: id)
    }

    internal func logCustom(_ event: String, data: ActitoEventData?, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await logCustom(event, data: data)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    internal func logCustom(_ event: String, data: ActitoEventData?) async throws {
        guard Actito.shared.isReady else {
            throw ActitoError.notReady
        }

        try await log("re.notifica.event.custom.\(event)", data: data)
    }

    // MARK: - Actito Internal Events

    internal func log(_ event: String, data: ActitoEventData?, sessionId: String?, notificationId: String?) async throws {
        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        let event = ActitoEvent(
            type: event,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000),
            deviceId: device.id,
            sessionId: sessionId ?? Actito.shared.session().sessionId,
            notificationId: notificationId,
            userId: device.userId,
            data: data
        )

        try await log(event)
    }

    // MARK: - Internal API

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

    private func log(_ event: ActitoEvent) async throws {
        guard Actito.shared.isConfigured else {
            logger.debug("Actito is not configured. Cannot log the event.")
            throw ActitoError.notConfigured
        }

        do {
            try await ActitoRequest.Builder()
                .post("/event", body: event)
                .response()

            logger.info("Event '\(event.type)' sent successfully.")
        } catch {
            logger.warning("Failed to send the event '\(event.type)'.", error: error)

            if !discardableEvents.contains(event.type), let error = error as? ActitoNetworkError, error.recoverable {
                logger.info("Queuing event to be sent whenever possible.")

                await Actito.shared.database.add(event)
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
            await UIApplication.shared.endBackgroundTask(taskId)
            self.processEventsTaskIdentifier = nil
        }
    }

    private func process(_ managedEvents: [NotificareCoreDataEvent]) async {
        guard !managedEvents.isEmpty else {
            logger.debug("Nothing to process.")
            return
        }

        var eventsRemaining = managedEvents.count

        for event in managedEvents {
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

    private func process(_ managedEvent: NotificareCoreDataEvent) async {
        let createdAt = await Actito.shared.database.backgroundContext.performCompat {
            Date(timeIntervalSince1970: Double(managedEvent.timestamp / 1000))
        }

        let expiresAt = await Actito.shared.database.backgroundContext.performCompat {
            createdAt.addingTimeInterval(Double(managedEvent.ttl))
        }

        let now = Date()

        if now > expiresAt {
            logger.debug("Event expired. Removing...")
            await Actito.shared.database.remove(managedEvent)
            return
        }

        let event: ActitoEvent

        do {
            event = try await Actito.shared.database.backgroundContext.performCompat({
                try ActitoEvent(from: managedEvent)
            })
        } catch {
            logger.debug("Cleaning up a corrupted event in the database.")
            await Actito.shared.database.remove(managedEvent)
            return
        }

        do {
            try await ActitoRequest.Builder()
                .post("/event", body: event)
                .response()

            logger.debug("Event processed. Removing from storage...")
            await Actito.shared.database.remove(managedEvent)
        } catch {
            if let error = error as? ActitoNetworkError, error.recoverable {
                logger.debug("Failed to process event.")

                // Increase the attempts counter.
                managedEvent.retries += 1

                if managedEvent.retries < MAX_RETRIES {
                    // Persist the attempts counter.
                    await Actito.shared.database.saveChanges()
                } else {
                    logger.debug("Event was retried too many times. Removing...")
                    await Actito.shared.database.remove(managedEvent)
                }
            } else {
                logger.debug("Failed to process event due to an unrecoverable error. Discarding it...")
                await Actito.shared.database.remove(managedEvent)
            }
        }
    }

    @objc private func onApplicationDidBecomeActiveNotification(_: Notification) {
        guard Actito.shared.isReady else { return }

        processStoredEvents()
    }

    @objc private func onReachabilityChanged(_: Notification) {
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
