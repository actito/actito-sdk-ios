//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import SwiftUI

internal struct RegionConfigSection: View {
    internal let regionConfig = Actito.shared.application?.regionConfig

    internal var body: some View {
        Section {
            HStack {
                Text(String(localized: "application_region_config_proximity_uuid"))

                Spacer()

                Text(String(describing: regionConfig!.proximityUUID!))
            }
        } header: {
            Text(String(localized: "application_region_config_header"))
        }
    }
}

internal struct RegionConfigSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            RegionConfigSection()
        }
    }
}
