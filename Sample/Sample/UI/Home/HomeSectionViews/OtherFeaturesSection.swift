//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI

internal struct OtherFeaturesSection: View {
    internal var body: some View {
        Section {
            NavigationLink {
                AssetsView()
            } label: {
                Label {
                    Text(String(localized: "home_assets"))
                } icon: {
                    ListIconView(
                        icon: "folder.fill",
                        foregroundColor: .white,
                        backgroundColor: Color(.systemIndigo)
                    )
                }
            }
        } header: {
            Text(String(localized: "home_other_features"))
        }
    }
}

internal struct OtherFeaturesSection_Previews: PreviewProvider {
    internal static var previews: some View {
        OtherFeaturesSection()
    }
}
