//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI

internal struct BeaconsView: View {
    @StateObject private var viewModel = BeaconsViewModel()

    internal var body: some View {
        List {
            Section {
                if let rangedBeacons = viewModel.rangedBeacons, !rangedBeacons.beacons.isEmpty {
                    ForEach(rangedBeacons.beacons) { beacon in
                        BeaconRow(
                            region: rangedBeacons.region,
                            beacon: beacon
                        )
                    }
                } else {
                    Label(String(localized: "beacons_not_found"), systemImage: "info.circle.fill")
                }
            } header: {
                HStack {
                    Text(String(localized: "beacons_header"))

                    ChipView(text: String(describing: viewModel.rangedBeacons?.beacons.count ?? 0))
                }
            }
        }
        .navigationTitle(String(localized: "beacons_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

internal struct BeaconsView_Previews: PreviewProvider {
    internal static var previews: some View {
        BeaconsView()
    }
}
