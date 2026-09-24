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
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .separator))
                )

            TextField(String(localized: "device_register_user_name"), text: $userName)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .separator))
                )

            Button {
                registerUser(userId, userName)
                userId = ""
                userName = ""
            } label: {
                Text(String(localized: "device_register_user_button"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(userId.isEmpty)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            HStack {
                Button {
                    registerAnonymousUser()
                } label: {
                    Text(String(localized: "device_register_user_anonymous_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isDeviceRegistered)

                Button {
                    registerUser("sample.user@actito.com", "Sample User")
                } label: {
                    Text(String(localized: "device_register_user_sample_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
        } header: {
            Text(String(localized: "device_register_user_header"))
        }
        .listRowSeparator(.hidden)
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
