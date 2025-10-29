//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import UIKit

@MainActor
public final class ActitoAutoConfig: NSObject {
    @objc public static func setup() {
        addApplicationLaunchListener()
    }

    private static func addApplicationLaunchListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinishLaunching),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
    }

    private static func removeApplicationLaunchListener() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
    }

    @objc private static func didFinishLaunching() {
        removeApplicationLaunchListener()
        autoConfigure()
    }

    private static func autoConfigure() {
        guard shouldAutoConfigure() else {
            logger.debug("Skipping automatic configuration...")
            return
        }

        Actito.shared.configure()
    }

    private static func shouldAutoConfigure() -> Bool {
        guard Actito.shared.state == .none else {
            logger.debug("Actito has already been configured.")
            return false
        }

        guard let options = loadOptions() else {
            return true
        }

        if !options.autoConfig {
            logger.debug("Actito auto config is disabled.")
        }

        return options.autoConfig
    }

    private static func loadOptions() -> ActitoOptions? {
        guard let path = Bundle.main.path(
            forResource: ActitoOptions.fileName,
            ofType: ActitoOptions.fileExtension
        ) else { return nil }

        return ActitoOptions(contentsOfFile: path)
    }
}
