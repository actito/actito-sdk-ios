//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation
import UIKit

@MainActor
internal class ActitoCrashReporterComponent {
    internal static let instance = ActitoCrashReporterComponent()

    // MARK: - Internal API

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

    internal func launch() async {
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

    internal let uncaughtExceptionHandler: @convention(c) (NSException) -> Void = { exception in
        guard let device = Actito.shared.device().currentDevice else {
            logger.warning("Cannot process a crash report before the device becomes available.")
            return
        }

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)

        LocalStorage.crashReport = ActitoInternals.PushAPI.Payloads.CreateEventPayload(
            type: "re.notifica.event.application.Exception",
            timestamp: timestamp,
            deviceId: device.id,
            sessionId: Actito.shared.session().sessionId,
            notificationId: nil,
            userId: device.userId,
            data: [
                "platform": "iOS",
                "osVersion": UIDevice.current.osVersion,
                "deviceString": UIDevice.current.deviceString,
                "sdkVersion": Actito.SDK_VERSION,
                "appVersion": Bundle.main.applicationVersion,
                "timestamp": timestamp,
                "name": exception.name.rawValue,
                "reason": exception.reason as any Sendable,
                "stackSymbols": exception.callStackSymbols.joined(separator: "\n"),
            ]
        )
    }

    internal let signalReceiver: @convention(c) (Int32) -> Void = { signal in
        guard let device = Actito.shared.device().currentDevice else {
            logger.warning("Cannot process a crash report before the device becomes available.")
            return
        }

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let stackSymbols = Thread.callStackSymbols.joined(separator: "\n")
        let name: String

        switch signal {
        case SIGQUIT: name = "SIGQUIT"
        case SIGILL: name = "SIGILL"
        case SIGTRAP: name = "SIGTRAP"
        case SIGABRT: name = "SIGABRT"
        case SIGEMT: name = "SIGEMT"
        case SIGFPE: name = "SIGFPE"
        case SIGBUS: name = "SIGBUS"
        case SIGSEGV: name = "SIGSEGV"
        case SIGSYS: name = "SIGSYS"
        case SIGPIPE: name = "SIGPIPE"
        case SIGALRM: name = "SIGALRM"
        case SIGXCPU: name = "SIGXCPU"
        case SIGXFSZ: name = "SIGXFSZ"
        default: name = "Unknown"
        }

        LocalStorage.crashReport = ActitoInternals.PushAPI.Payloads.CreateEventPayload(
            type: "re.notifica.event.application.Exception",
            timestamp: timestamp,
            deviceId: device.id,
            sessionId: Actito.shared.session().sessionId,
            notificationId: nil,
            userId: device.userId,
            data: [
                "platform": "iOS",
                "osVersion": UIDevice.current.osVersion,
                "deviceString": UIDevice.current.deviceString,
                "sdkVersion": Actito.SDK_VERSION,
                "appVersion": Bundle.main.applicationVersion,
                "timestamp": timestamp,
                "name": name,
                "reason": "Uncaught Signal \(name)",
                "stackSymbols": stackSymbols,
            ]
        )
    }
}
