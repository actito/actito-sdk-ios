//
// Copyright (c) 2025 Actito. All rights reserved.
//

internal final class CrashReporterLaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = CrashReporterLaunchComponent()

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        let crashReportsEnabled = Actito.shared.options!.crashReportsEnabled

        guard crashReportsEnabled else {
            return
        }

        logger.warning("Crash reporting is deprecated. We recommend using another solution to collect crash analytics.")

        // Catch NSExceptions
        NSSetUncaughtExceptionHandler(Actito.shared.crashReporter().uncaughtExceptionHandler)

        // Catch Swift exceptions
        signal(SIGQUIT, Actito.shared.crashReporter().signalReceiver)
        signal(SIGILL, Actito.shared.crashReporter().signalReceiver)
        signal(SIGTRAP, Actito.shared.crashReporter().signalReceiver)
        signal(SIGABRT, Actito.shared.crashReporter().signalReceiver)
        signal(SIGEMT, Actito.shared.crashReporter().signalReceiver)
        signal(SIGFPE, Actito.shared.crashReporter().signalReceiver)
        signal(SIGBUS, Actito.shared.crashReporter().signalReceiver)
        signal(SIGSEGV, Actito.shared.crashReporter().signalReceiver)
        signal(SIGSYS, Actito.shared.crashReporter().signalReceiver)
        signal(SIGPIPE, Actito.shared.crashReporter().signalReceiver)
        signal(SIGALRM, Actito.shared.crashReporter().signalReceiver)
        signal(SIGXCPU, Actito.shared.crashReporter().signalReceiver)
        signal(SIGXFSZ, Actito.shared.crashReporter().signalReceiver)
    }

    internal func clearStorage() async throws {
        // no-op
    }

    internal func launch() async throws {
        guard let event = LocalStorage.crashReport else {
            logger.debug("No crash report to process.")
            return
        }

        do {
            try await ActitoRequest.Builder()
                .post("/event", body: event)
                .response()

            logger.info("Crash report processed.")

            // Clean up the stored crash report
            LocalStorage.crashReport = nil
        } catch {
            logger.error("Failed to process a crash report.", error: error)

        }
    }

    internal func postLaunch() async throws {
        // no-op
    }

    internal func unlaunch() async throws {
        // no-op
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> (any Sendable)? {
        return nil
    }
}
