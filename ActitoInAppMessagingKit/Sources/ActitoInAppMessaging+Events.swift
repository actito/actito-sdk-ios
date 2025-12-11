//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

extension ActitoEventsComponent {
    internal func logInAppMessageViewed(_ message: ActitoInAppMessage) async throws {
        try await log("re.notifica.event.inappmessage.View", data: ["message": message.id])
    }

    internal func logInAppMessageActionClicked(_ message: ActitoInAppMessage, action: ActitoInAppMessage.ActionType) async throws {
        try await log(
            "re.notifica.event.inappmessage.Action",
            data: [
                "message": message.id,
                "action": action.rawValue,
            ]
        )
    }
}
