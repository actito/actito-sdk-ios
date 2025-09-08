//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension ActitoInternals.PushAPI.Responses {
    internal struct Application: Decodable, Sendable {
        internal let application: ActitoInternals.PushAPI.Models.Application
    }

    internal struct CreateDevice: Decodable {
        internal let device: Device

        internal struct Device: Decodable {
            internal let deviceID: String
        }
    }

    internal struct Tags: Decodable {
        internal let tags: [String]
    }

    internal struct DoNotDisturb: Decodable {
        internal let dnd: ActitoDoNotDisturb?
    }

    internal struct UserData: Decodable {
        internal let userData: [String: String?]?
    }

    internal struct DynamicLink: Decodable {
        internal let link: ActitoDynamicLink
    }

    internal struct Notification: Decodable, Sendable {
        internal let notification: ActitoInternals.PushAPI.Models.Notification
    }

    internal struct UploadAsset: Decodable {
        internal let filename: String
    }
}
