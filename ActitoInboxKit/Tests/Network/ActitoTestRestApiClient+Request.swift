//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import ActitoTestSupportKit

extension ActitoTestRestApiClient {
    internal static func sendPushNotification(deviceId: String) async throws {
        let url = "/notification/push/device/\(deviceId)"

        let body = [
            "type": "re.notifica.notification.Alert",
            "message": "Massive open test",
        ]

        _ = try await post(url: url, body: body)
    }
}
