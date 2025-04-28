//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActivityKit
import CoreLocation
import Foundation
import OSLog
import StoreKit
import SwiftUI
import UIKit

internal class AppDelegate: NSObject, UIApplicationDelegate {
    internal var window: UIWindow?

    internal func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Enable Proxyman debugging.
        // Atlantis.start()

        Actito.shared.delegate = self

        Task {
            do {
                try await Actito.shared.launch()
            } catch {
                Logger.main.error("Failed to launch Actito. \(error)")
            }
        }

        if Actito.shared.canEvaluateDeferredLink {
            Actito.shared.evaluateDeferredLink { result in
                switch result {
                case let .success(evaluated):
                    Logger.main.info("deferred link evaluation = \(evaluated)")
                case let .failure(error):
                    Logger.main.error("Failed to evaluate the deferred link. \(error)")
                }
            }
        }

        return true
    }

    internal func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken _: Data) {}

    internal func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    internal func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any], fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {}
}

extension AppDelegate: ActitoDelegate {
    internal func actito(_: Actito, onReady _: ActitoApplication) {
        Logger.main.info("Actito finished launching.")

        registerUser()

        NotificationCenter.default.post(
            name: .actitoStatus,
            object: nil,
            userInfo: ["ready": true]
        )
    }

    internal func actitoDidUnlaunch(_: Actito) {
        Logger.main.info("Actito finished un-launching.")

        NotificationCenter.default.post(
            name: .actitoStatus,
            object: nil,
            userInfo: ["ready": false]
        )
    }

    internal func actito(_: Actito, didRegisterDevice device: ActitoDevice) {
        Logger.main.info("Actito: device registered: \(String(describing: device))")
    }

    private func registerUser() {
        guard let user = SampleUser.loadFromPlist() else {
            return
        }

        let userId = user.userId.isEmpty ? nil : user.userId
        let userName = user.userName.isEmpty ? nil : user.userName

        Task {
            do {
                Logger.main.info("Registering device")
                try await Actito.shared.device().updateUser(userId: userId, userName: userName)
                Logger.main.info("Device registered successfully")
            } catch {
                Logger.main.error("Failed to registered device: \(error)")
            }
        }
    }
}
