//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import SwiftUI

internal struct ApplicationInfoSection: View {
    internal let application = Actito.shared.application

    internal var body: some View {
        Section {
            HStack {
                Text(String(localized: "application_application_info_id"))

                Spacer()

                Text(verbatim: application!.id)
            }

            HStack {
                Text(String(localized: "application_application_info_name"))

                Spacer()

                Text(verbatim: application!.name)
            }

            HStack {
                Text(String(localized: "application_application_info_category"))

                Spacer()

                Text(verbatim: application!.category)
            }

            HStack {
                Text(String(localized: "application_application_info_enforce_size_limit"))

                Spacer()

                Text(String(describing: application!.enforceSizeLimit!))
            }

            HStack {
                Text(String(localized: "application_application_info_enforce_tag_restrictions"))

                Spacer()

                Text(String(describing: application!.enforceTagRestrictions!))
            }

            HStack {
                Text(String(localized: "application_application_info_enforce_event_name_restrictions"))

                Spacer()

                Text(String(describing: application!.enforceEventNameRestrictions!))
            }
        } header: {
            Text(String(localized: "application_application_info_header"))
        }
    }
}

internal struct ApplicationInfoSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            ApplicationInfoSection()
        }
    }
}
