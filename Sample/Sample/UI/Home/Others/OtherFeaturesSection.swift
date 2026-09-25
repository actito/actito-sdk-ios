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
                    Text(String(localized: "home_other_features_assets"))
                } icon: {
                    ListIconView(
                        icon: "folder.fill",
                        foregroundColor: .white,
                        backgroundColor: .yellow
                    )
                }
            }

            NavigationLink {
                EventsView()
            } label: {
                Label {
                    Text(String(localized: "home_other_features_custom_events"))
                } icon: {
                    ListIconView(
                        icon: "light.beacon.max",
                        foregroundColor: .white,
                        backgroundColor: .green
                    )
                }
            }
        } header: {
            Text(String(localized: "home_other_features_header"))
        }
    }
}

internal struct OtherFeaturesSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            OtherFeaturesSection()
        }
    }
}
