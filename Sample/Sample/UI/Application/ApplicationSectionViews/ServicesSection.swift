//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import SwiftUI

internal struct ServicesSection: View {
    internal let services = Actito.shared.application?.services

    internal var body: some View {
        Section {
            ForEach(Array(services!.keys), id: \.self) { service in
                HStack {
                    Text(verbatim: service)

                    Spacer()

                    Text(String(describing: services![service]!))
                }
            }
        } header: {
            Text(String(localized: "application_services_header"))
        }
    }
}

internal struct ServicesSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            ServicesSection()
        }
    }
}
