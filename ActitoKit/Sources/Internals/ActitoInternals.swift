//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

public enum ActitoInternals {
    public enum Module: String, CaseIterable {
        // Embedded modules
        case device = "ActitoKit.DeviceLaunchComponent"
        case session = "ActitoKit.SessionLaunchComponent"
        case events = "ActitoKit.EventsLaunchComponent"
        case crashReporter = "ActitoKit.CrashReporterLaunchComponent"

        // Peer modules
        case push = "ActitoPushKit.LaunchComponent"
        case pushUI = "ActitoPushUIKit.LaunchComponent"
        case inbox = "ActitoInboxKit.LaunchComponent"
        case loyalty = "ActitoLoyaltyKit.LaunchComponent"
        case assets = "ActitoAssetsKit.LaunchComponent"
        case geo = "ActitoGeoKit.LaunchComponent"
        case inAppMessaging = "ActitoInAppMessagingKit.LaunchComponent"
        case userInbox = "ActitoUserInboxKit.LaunchComponent"

        public var isAvailable: Bool {
            NSClassFromString(rawValue) != nil
        }

        public var klass: (any ActitoLaunchComponent.Type)? {
            NSClassFromString(rawValue) as? any ActitoLaunchComponent.Type
        }

        internal var isPeer: Bool {
            switch self {
            case .device, .events, .session, .crashReporter:
                return false
            default:
                return true
            }
        }
    }
}
