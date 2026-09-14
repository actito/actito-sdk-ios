//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import SwiftUI

internal struct CurrentDeviceSection: View {
    internal let device: ActitoDevice?
    internal let language: String?

    private var deviceDnd: String? {
        device?.dnd.map { dnd in
            "\(String(format: "%02d:%02d", dnd.start.hours, dnd.start.minutes)) to \(String(format: "%02d:%02d", dnd.end.hours, dnd.end.minutes))"
        }
    }

    internal var body: some View {
        if let device {
            Section {
                HStack {
                    Text(String(localized: "device_current_device_id"))

                    Spacer()

                    Text(device.id)
                }
                HStack {
                    Text(String(localized: "device_current_device_user_id"))

                    Spacer()

                    Text(device.userId ?? "nil")
                }
                HStack {
                    Text(String(localized: "device_current_device_user_name"))

                    Spacer()

                    Text(device.userName ?? "nil")
                }
                HStack {
                    Text(String(localized: "device_current_device_do_not_disturb"))

                    Spacer()

                    Text(deviceDnd ?? "nil")
                }
                HStack {
                    Text(String(localized: "device_current_device_preferred_language"))

                    Spacer()

                    Text(language ?? "nil")
                }
            } header: {
                Text(String(localized: "device_current_device_header"))
            }
        }
    }
}

internal struct CurrentDeviceSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            CurrentDeviceSection(
                device: ActitoDevice(
                    id: "ID",
                    userId: "userID",
                    userName: "UserName",
                    timeZoneOffset: 1.0,
                    dnd: nil,
                    userData: ["firstName": "First Name"],
                    backgroundAppRefresh: true,
                ),
                language: "pt-PT"
            )
        }
    }
}
