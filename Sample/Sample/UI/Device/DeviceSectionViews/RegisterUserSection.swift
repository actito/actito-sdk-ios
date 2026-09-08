//
// Copyright (c) 2026 Actito. All rights reserved.
//

import SwiftUI

internal struct RegisterUserSection: View {
    @State internal var userId: String = ""
    @State internal  var userName: String = ""

    internal let isDeviceRegistered: Bool
    internal let registerUser: (String, String) -> Void
    internal let registerAnonymousUser: () -> Void

    internal var body: some View {
        Section {
            TextField(String(localized: "device_register_user_id"), text: $userId)
                .autocorrectionDisabled()
                .autocapitalization(.none)

            TextField(String(localized: "device_register_user_name"), text: $userName)
                .autocorrectionDisabled()
                .autocapitalization(.none)

            Button(String(localized: "device_register_user_button")) {
                registerUser(userId, userName)
                userId = ""
                userName = ""
            }
            .frame(maxWidth: .infinity)
            .disabled(userId.isEmpty)

            HStack {
                Button(String(localized: "device_register_user_anonymous_button")) {
                    registerAnonymousUser()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)
                .disabled(!isDeviceRegistered)

                Button(String(localized: "device_register_user_sample_button")) {
                    registerUser("sample.user@actito.com", "Sample User")
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)
            }
        } header: {
            Text(String(localized: "device_register_user_header"))
        }
    }
}

internal struct RegisterUserSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            RegisterUserSection(
                isDeviceRegistered: false,
                registerUser: { _, _ in},
                registerAnonymousUser: {}
            )
        }
    }
}
