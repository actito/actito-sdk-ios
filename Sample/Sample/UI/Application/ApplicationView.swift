//
// Copyright (c) 2026 Actito. All rights reserved.
//

import SwiftUI

internal struct ApplicationView: View {
    internal var body: some View {
        List {
            ApplicationInfoSection()

            InboxConfigSection()

            RegionConfigSection()

            ServicesSection()

            UserDataFieldsSection()

            ActionCategoriesSection()
        }
        .navigationTitle(String(localized: "application_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

internal struct ApplicationView_Previews: PreviewProvider {
    internal static var previews: some View {
        ApplicationView()
    }
}
