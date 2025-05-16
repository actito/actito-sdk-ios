//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

public enum ActitoInternals {
    public enum Module: String, CaseIterable {
        // Embedded modules
        case device = "ActitoKit.ActitoDeviceModuleImpl"
        case session = "ActitoKit.ActitoSessionModuleImpl"
        case events = "ActitoKit.ActitoEventsModuleImpl"
        case crashReporter = "ActitoKit.ActitoCrashReporterModuleImpl"

        // Peer modules
        case push = "ActitoPushKit.ActitoPushImpl"
        case pushUI = "ActitoPushUIKit.ActitoPushUIImpl"
        case inbox = "ActitoInboxKit.ActitoInboxImpl"
        case loyalty = "ActitoLoyaltyKit.ActitoLoyaltyImpl"
        case assets = "ActitoAssetsKit.ActitoAssetsImpl"
        case scannables = "ActitoScannablesKit.ActitoScannablesImpl"
        case geo = "ActitoGeoKit.ActitoGeoImpl"
        case inAppMessaging = "ActitoInAppMessagingKit.ActitoInAppMessagingImpl"
        case userInbox = "ActitoUserInboxKit.ActitoUserInboxImpl"

        public var isAvailable: Bool {
            NSClassFromString(rawValue) != nil
        }

        public var klass: (any ActitoModule.Type)? {
            NSClassFromString(rawValue) as? any ActitoModule.Type
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
