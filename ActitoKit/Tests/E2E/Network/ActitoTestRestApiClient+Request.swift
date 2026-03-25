//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import ActitoTestSupportKit

extension ActitoTestRestApiClient {
    internal static func getRemoteDevice() async throws -> TestDeviceResponse.Device {
        guard let localDevice = await Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        let deviceResponse = try await get(url: "/device/\(localDevice.id)")

        guard let data = deviceResponse.data else {
            throw ActitoError.invalidArgument(message: "Empty response")
        }

        let decoded = try JSONDecoder().decode(TestDeviceResponse.self, from: data)
        return decoded.device
    }

    internal static func getDeviceCustomEvents(deviceId: String, event: String) async throws -> TestCustomEventsResponse {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let today = Date()
        let sinceToday = formatter.string(from: today)
        let beforeTomorrow = formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: today)!)

        let result = try await get(
            url: "/event/fortype/re.notifica.event.custom.\(event)",
            query: [
                "deviceID": deviceId,
                "since": sinceToday,
                "before": beforeTomorrow,
            ]
        )

        guard let data = result.data else {
            throw ActitoError.invalidArgument(message: "Empty response")
        }

        return try JSONDecoder().decode(TestCustomEventsResponse.self, from: data)
    }
}
