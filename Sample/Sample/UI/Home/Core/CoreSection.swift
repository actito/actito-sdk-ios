//
// Copyright (c) 2026 Actito. All rights reserved.
//

import SwiftUI

internal struct CoreSection: View {
    internal var body: some View {
        Section {
            NavigationLink {
                ApplicationView()
            } label: {
                Label {
                    Text(String(localized: "home_core_application"))
                } icon: {
                    ListIconView(
                        icon: "info.circle.fill",
                        foregroundColor: .white,
                        backgroundColor: .red
                    )
                }
            }

            NavigationLink {
                DeviceView()
            } label: {
                Label {
                    Text(String(localized: "home_core_device"))
                } icon: {
                    ListIconView(
                        icon: "iphone.gen1",
                        foregroundColor: .white,
                        backgroundColor: .orange
                    )
                }
            }

            NavigationLink {
                TagsView()
            } label: {
                Label {
                    Text(String(localized: "home_core_tags"))
                } icon: {
                    ListIconView(
                        icon: "tag.fill",
                        foregroundColor: .white,
                        backgroundColor: .yellow
                    )
                }
            }
        }
    }
}

internal struct CoreSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            CoreSection()
        }
    }
}
