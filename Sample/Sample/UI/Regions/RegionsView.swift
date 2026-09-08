//
// Copyright (c) 2026 Actito. All rights reserved.
//

import SwiftUI

internal struct RegionsView: View {
    @StateObject private var viewModel = RegionsViewModel()

    internal var body: some View {
        List {
            Section {
                if viewModel.enteredRegions.isEmpty {
                    Label(String(localized: "regions_entered_not_found"), systemImage: "info.circle.fill")
                } else {
                    ForEach(viewModel.enteredRegions) { region in
                        RegionRow(region: region)
                    }
                }
            } header: {
                HStack {
                    Text(String(localized: "regions_entered_header"))

                    ChipView(text: String(describing: viewModel.enteredRegions.count))
                }
            }

            Section {
                if viewModel.monitoredRegions.isEmpty {
                    Label(String(localized: "regions_monitored_not_found"), systemImage: "info.circle.fill")
                } else {
                    ForEach(viewModel.monitoredRegions) { region in
                        RegionRow(region: region)
                    }
                }
            } header: {
                HStack {
                    Text(String(localized: "regions_monitored_header"))

                    ChipView(text: String(describing: viewModel.enteredRegions.count))
                }
            }
        }
        .navigationTitle(String(localized: "regions_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

internal struct RegionsView_Previews: PreviewProvider {
    internal static var previews: some View {
        RegionsView()
    }
}
