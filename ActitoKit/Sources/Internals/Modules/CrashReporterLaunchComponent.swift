//
// Copyright (c) 2025 Actito. All rights reserved.
//

internal class CrashReporterLaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = CrashReporterLaunchComponent()

    internal let implementation = ActitoCrashReporterModuleImpl.instance

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        let crashReportsEnabled = Actito.shared.options!.crashReportsEnabled

        guard crashReportsEnabled else {
            logger.debug("Crash reports are not enabled.")
            return
        }

        // Catch NSExceptions
        NSSetUncaughtExceptionHandler(implementation.uncaughtExceptionHandler)

        // Catch Swift exceptions
        signal(SIGQUIT, implementation.signalReceiver)
        signal(SIGILL, implementation.signalReceiver)
        signal(SIGTRAP, implementation.signalReceiver)
        signal(SIGABRT, implementation.signalReceiver)
        signal(SIGEMT, implementation.signalReceiver)
        signal(SIGFPE, implementation.signalReceiver)
        signal(SIGBUS, implementation.signalReceiver)
        signal(SIGSEGV, implementation.signalReceiver)
        signal(SIGSYS, implementation.signalReceiver)
        signal(SIGPIPE, implementation.signalReceiver)
        signal(SIGALRM, implementation.signalReceiver)
        signal(SIGXCPU, implementation.signalReceiver)
        signal(SIGXFSZ, implementation.signalReceiver)
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

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}
