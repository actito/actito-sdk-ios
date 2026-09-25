//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI

internal struct LaunchSection: View {
    @StateObject private var viewModel = LaunchViewModel()

    internal var body: some View {
        Section {
            HStack {
                Text(String(localized: "home_launch_configured"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(viewModel.isConfigured))
            }

            HStack {
                Text(String(localized: "home_launch_ready"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(viewModel.isReady))
            }

            HStack {
                Button {
                    viewModel.actitoUnlaunch()
                } label: {
                    Text(String(localized: "home_unlaunch_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isReady)

                Button {
                    viewModel.actitoLaunch()
                } label: {
                    Text(String(localized: "home_launch_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isReady)
            }
            .listRowSeparator(.hidden)
        } header: {
            Text(String(localized: "home_launch_header"))
        }
    }
}

internal struct LaunchSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            LaunchSection()
        }
    }
}
