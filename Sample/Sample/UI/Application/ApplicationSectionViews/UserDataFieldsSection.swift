//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import SwiftUI

internal struct UserDataFieldsSection: View {
    internal let userDataFields = Actito.shared.application?.userDataFields

    internal var body: some View {
        Section {
            if let userDataFields {
                ForEach(userDataFields, id: \.key) { field in
                    VStack(spacing: 8) {
                        HStack {
                            Text(String(localized: "application_user_data_fields_type"))
                            Spacer()
                            Text(String(describing: field.type))
                        }
                        HStack {
                            Text(String(localized: "application_user_data_fields_key"))
                            Spacer()
                            Text(String(describing: field.key))
                        }
                        HStack {
                            Text(String(localized: "application_user_data_fields_label"))
                            Spacer()
                            Text(String(describing: field.label))
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text(String(localized: "application_user_data_fields_header"))

                ChipView(text: String(describing: userDataFields!.count))
            }
        }
    }
}

internal struct UserDataFieldsSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            UserDataFieldsSection()
        }
    }
}
