//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import SwiftUI

internal struct UserDataSection: View {
    @State internal var firstName: String = ""
    @State internal var lastName: String = ""

    internal let userData: ActitoUserData?
    internal let updateUserData: ([String: String?]) -> Void

    private let sampleUserData = ["firstName": "Sample First Name", "lastName": "Sample Last Name"]

    private var sortedUserData: [(key: String, value: String)] {
        (userData ?? [:]).sorted { $0.key < $1.key }
    }

    private var hasUserData: Bool {
        userData?.isEmpty == false
    }

    internal var body: some View {
        if hasUserData {
            Section {
                ForEach(sortedUserData, id: \.key) { item in
                    HStack {
                        Text(item.key)
                        Spacer()
                        Text(item.value)
                    }
                }
            } header: {
                userDataHeader
            }
        }

        Section {
            TextField(String(localized: "device_user_data_first_name"), text: $firstName)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .separator))
                )

            TextField(String(localized: "device_user_data_last_name"), text: $lastName)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .separator))
                )

            Button {
                let data = ["firstName": firstName, "lastName": lastName]
                    .filter{ !$0.value.isEmpty }
                updateUserData(data)
            } label: {
                Text(String(localized: "device_user_data_button"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(firstName.isEmpty && lastName.isEmpty)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            HStack {
                Button {
                    let data = ["firstName": firstName, "lastName": nil]
                        .filter{ $0.value?.isEmpty != true }
                    updateUserData(data)
                } label: {
                    Text(String(localized: "device_user_data_remove_last_name_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(userData?["lastName"] == nil)

                Button {
                    updateUserData(sampleUserData)
                } label: {
                    Text(String(localized: "device_user_data_quick_update_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
        } header: {
            if !hasUserData {
                userDataHeader
            }
        }
        .listRowSeparator(.hidden)
    }

    private var userDataHeader: some View {
        HStack {
            Text(String(localized: "device_user_data_header"))

            ChipView(text: String(describing: userData?.count ?? 0))
        }
    }
}

internal struct UserDataSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            UserDataSection(
                userData: ["firstName": "First Name", "lastName": "Last Name"],
                updateUserData: { _ in }
            )
        }
    }
}
