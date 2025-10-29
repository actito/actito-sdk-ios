//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension ActitoInternals.PushAPI.Models {
    internal struct Message: Decodable, Equatable {
        internal let _id: String
        internal let name: String
        internal let type: String
        internal let context: [String]?
        internal let title: String?
        internal let message: String?
        internal let image: String?
        internal let landscapeImage: String?
        internal let delaySeconds: Int?
        internal let primaryAction: Action?
        internal let secondaryAction: Action?

        internal struct Action: Decodable, Equatable {
            internal let label: String?
            internal let destructive: Bool
            internal let url: String?
        }

        internal func toModel() -> ActitoInAppMessage {
            ActitoInAppMessage(
                id: _id,
                name: name,
                type: type,
                context: context ?? [],
                title: title,
                message: message,
                image: image,
                landscapeImage: landscapeImage,
                delaySeconds: delaySeconds ?? 0,
                primaryAction: primaryAction.map {
                    ActitoInAppMessage.Action(
                        label: $0.label,
                        destructive: $0.destructive,
                        url: $0.url
                    )
                },
                secondaryAction: secondaryAction.map {
                    ActitoInAppMessage.Action(
                        label: $0.label,
                        destructive: $0.destructive,
                        url: $0.url
                    )
                }
            )
        }
    }
}
