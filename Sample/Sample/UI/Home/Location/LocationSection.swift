//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI

internal struct LocationSection: View {
    @StateObject private var viewModel = LocationViewModel()

    internal var body: some View {
        Section {
            Toggle(isOn: $viewModel.hasLocationAndPermission) {
                Label {
                    Text(String(localized: "home_location"))
                } icon: {
                    ListIconView(
                        icon: "location.fill",
                        foregroundColor: .white,
                        backgroundColor: Color(.systemIndigo)
                    )
                }
            }
            .onChange(of: viewModel.hasLocationAndPermission) { enabled in
                viewModel.updateLocationServicesStatus(enabled: enabled)
            }

            HStack {
                Text(String(localized: "home_location_enabled"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(viewModel.hasLocationEnabled))
            }

            HStack {
                Text(String(localized: "home_location_bluetooth_enabled"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(viewModel.hasBluetoothEnabled))
            }

            HStack {
                Text(String(localized: "home_location_permission"))

                Spacer()

                Text(String(viewModel.locationPermission?.localized ?? ""))
            }

            NavigationLink {
                RegionsView()
            } label: {
                HStack {
                    Label {
                        Text(String(localized: "home_location_regions"))
                    } icon: {
                        ListIconView(
                            icon: "mappin.and.ellipse",
                            foregroundColor: .white,
                            backgroundColor: .purple
                        )
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        ChipView(text: String(localized: "home_location_regions_entered_chip", viewModel.enteredRegions.count))
                        ChipView(text: String(localized: "home_location_regions_monitored_chip", viewModel.monitoredRegions.count))
                    }
                }
            }

            NavigationLink {
                BeaconsView()
            } label: {
                HStack {
                    Label {
                        Text(String(localized: "home_location_beacons"))
                    } icon: {
                        ListIconView(
                            icon: "sensor.tag.radiowaves.forward",
                            foregroundColor: .white,
                            backgroundColor: .pink
                        )
                    }

                    Spacer()

                    ChipView(
                        text: String(localized: "home_location_beacons_ranged_chip", viewModel.rangedBeacons.count))
                }
            }
        } header: {
            Text(String(localized: "home_location_header"))
        }
    }
}

internal struct LocationSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            LocationSection()
        }
    }
}
