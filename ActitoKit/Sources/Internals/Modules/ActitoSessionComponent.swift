//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation
import UIKit

private let SESSION_CLOSE_TASK_NAME = "re.notifica.tasks.session.Close"

@MainActor
internal class ActitoSessionComponent {
    internal static let instance = ActitoSessionComponent()

    internal private(set) var sessionId: String?
    private var sessionStart: Date?
    internal var sessionEnd: Date?

    private var backgroundTask: DispatchWorkItem?
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        return formatter
    }()

    // MARK: - Internal API

    internal func configure() {
        // Listen to 'application did become active'
        NotificationCenter.default.upsertObserver(
            Actito.shared.session(),
            selector: #selector(Actito.shared.session().applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to 'application will resign active'
        NotificationCenter.default.upsertObserver(
            Actito.shared.session(),
            selector: #selector(Actito.shared.session().applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    internal func launch() async throws {
        if
            Actito.shared.session().sessionId == nil,
            Actito.shared.device().currentDevice != nil,
            UIApplication.shared.applicationState == .active
        {
            // Launch is taking place after the application came to the foreground.
            // Start the application session.
            await Actito.shared.session().startSession()
        }
    }

    internal func unlaunch() async throws {
        Actito.shared.session().sessionEnd = Date()
        await Actito.shared.session().stopSession()
    }

    @objc internal func applicationDidBecomeActive() {
        guard UIApplication.shared.applicationState == .active else {
            logger.debug("The application is not active. Skipping...")
            return
        }

        if sessionId != nil {
            logger.debug("Resuming previous session.")
        }

        // Cancel any session timeout.
        cancelBackgroundTask()

        // Prevent multiple session starts.
        guard sessionId == nil else { return }

        guard Actito.shared.isReady else {
            logger.debug("Postponing session start until Actito is launched.")
            return
        }

        Task {
            await startSession()
        }
    }

    @objc internal func applicationWillResignActive() {
        guard UIApplication.shared.applicationState == .active else {
            logger.debug("The application is not active. Skipping...")
            return
        }

        sessionEnd = Date()

        // Wait a few seconds before sending a close event.
        // This prevents quick app swaps, navigation pulls, etc.
        let backgroundTask = createBackgroundTask()
        self.backgroundTask = backgroundTask
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10, execute: backgroundTask)

        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: SESSION_CLOSE_TASK_NAME) { [weak self] in
            logger.debug("Background task expiration handler triggered.")
            self?.cancelBackgroundTask()
        }
    }

    internal func startSession() async {
        let sessionId = UUID().uuidString.lowercased()
        let sessionStart = Date()

        self.sessionId = sessionId
        self.sessionStart = sessionStart
        sessionEnd = nil

        logger.debug("Session '\(sessionId)' started at \(dateFormatter.string(from: sessionStart)).")

        do {
            try await Actito.shared.eventsImplementation().logApplicationOpen(sessionId: sessionId)
        } catch {
            logger.warning("Failed to process an application session start.", error: error)
        }
    }

    private func stopSession(_ completion: @MainActor @escaping (Result<Void, Error>) -> Void) {
        Task {
            await stopSession()
            completion(.success(()))
        }
    }

    internal func stopSession() async {
        guard let sessionId = sessionId,
              let sessionStart = sessionStart,
              let sessionEnd = sessionEnd
        else {
            // Skip when no session has started. Should never happen.
            return
        }

        // Reset the session.
        self.sessionId = nil
        self.sessionStart = nil
        self.sessionEnd = nil

        logger.debug("Session '\(sessionId)' stopped at \(dateFormatter.string(from: sessionEnd)).")

        let length = sessionEnd.timeIntervalSince(sessionStart)

        do {
            try await Actito.shared.eventsImplementation().logApplicationClose(sessionId: sessionId, sessionLength: length)
        } catch {
            logger.warning("Failed to process an application session stop.", error: error)
        }
    }

    private nonisolated func createBackgroundTask() -> DispatchWorkItem {
        DispatchWorkItem {
            DispatchQueue.main.async {
                self.stopSession { _ in
                        self.cancelBackgroundTask()
                }
            }
        }
    }

    private func cancelBackgroundTask() {
        backgroundTask?.cancel()
        backgroundTask = nil

        if backgroundTaskIdentifier != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            backgroundTaskIdentifier = .invalid
        }
    }
}
