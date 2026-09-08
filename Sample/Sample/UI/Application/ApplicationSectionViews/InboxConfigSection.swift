//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import SwiftUI

internal struct InboxConfigSection: View {
    internal let inboxConfig = Actito.shared.application?.inboxConfig

    internal var body: some View {
        Section {
            HStack {
                Text(String(localized: "application_inbox_config_use_inbox"))

                Spacer()

                Text(String(describing: inboxConfig!.useInbox))
            }

            HStack {
                Text(String(localized: "application_inbox_config_use_user_inbox"))

                Spacer()

                Text(String(describing: inboxConfig!.useUserInbox))
            }

            HStack {
                Text(String(localized: "application_inbox_config_auto_badge"))

                Spacer()

                Text(String(describing: inboxConfig!.autoBadge))
            }
        } header: {
            Text(String(localized: "application_inbox_config_header"))
        }
    }
}

internal struct InboxConfigSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            InboxConfigSection()
        }
    }
}
