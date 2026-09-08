//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI

internal struct BeaconsView: View {
    @StateObject private var viewModel = BeaconsViewModel()

    internal var body: some View {
        List {
            if let rangedBeacons = viewModel.rangedBeacons {
                Section {
                    if rangedBeacons.beacons.isEmpty {
                        Label(String(localized: "beacons_not_found"), systemImage: "info.circle.fill")
                    } else {
                        ForEach(rangedBeacons.beacons) { beacon in
                            BeaconRow(
                                region: rangedBeacons.region,
                                beacon: beacon
                            )
                        }
                    }
                } header: {
                    HStack {
                        Text(String(localized: "beacons_header"))

                        ChipView(text: String(describing: rangedBeacons.beacons.count))
                    }
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
