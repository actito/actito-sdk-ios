//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import UIKit
import ActitoUtilitiesKit

internal class ActitoCrashReporterModuleImpl: NSObject, ActitoModule {
    // MARK: - Actito Module
    
    internal static let instance = ActitoCrashReporterModuleImpl()
    
    internal func configure() {
        let crashReportsEnabled = Actito.shared.options!.crashReportsEnabled
        
        guard crashReportsEnabled else {
            logger.debug("Crash reports are not enabled.")
            return
        }
        
        // Catch NSExceptions
        NSSetUncaughtExceptionHandler(uncaughtExceptionHandler)
        
        // Catch Swift exceptions
        signal(SIGQUIT, signalReceiver)
        signal(SIGILL, signalReceiver)
        signal(SIGTRAP, signalReceiver)
        signal(SIGABRT, signalReceiver)
        signal(SIGEMT, signalReceiver)
        signal(SIGFPE, signalReceiver)
        signal(SIGBUS, signalReceiver)
        signal(SIGSEGV, signalReceiver)
        signal(SIGSYS, signalReceiver)
        signal(SIGPIPE, signalReceiver)
        signal(SIGALRM, signalReceiver)
        signal(SIGXCPU, signalReceiver)
        signal(SIGXFSZ, signalReceiver)
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
    
    // MARK: - Internal API
    
    private let uncaughtExceptionHandler: @convention(c) (NSException) -> Void = { exception in
        guard let device = Actito.shared.device().currentDevice else {
            logger.warning("Cannot process a crash report before the device becomes available.")
            return
        }
        
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        
        LocalStorage.crashReport = ActitoEvent(
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
                "reason": exception.reason as Any,
                "stackSymbols": exception.callStackSymbols.joined(separator: "\n"),
            ]
        )
    }
    
    private let signalReceiver: @convention(c) (Int32) -> Void = { signal in
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
        
        LocalStorage.crashReport = ActitoEvent(
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
