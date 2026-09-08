//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoGeoKit
import Combine
import Foundation
import SwiftUI

internal class BeaconsViewModel: ObservableObject {
    @Published internal var rangedBeacons: RangedBeaconsData?

    private var cancellables = Set<AnyCancellable>()

    internal init() {
        observeRangedBeacons()
    }

    private func observeRangedBeacons() {
        NotificationCenter.default.publisher(for: .beaconsRanged)
            .sink { [weak self] notification in
                guard let region = notification.userInfo?["region"] as? ActitoRegion else {
                    return
                }

                guard let beacons = notification.userInfo?["beacons"] as? [ActitoBeacon] else {
                    return
                }

                self?.rangedBeacons = RangedBeaconsData(region: region, beacons: beacons)
            }
            .store(in: &cancellables)
    }
}

internal struct RangedBeaconsData {
    internal let region: ActitoRegion
    internal let beacons: [ActitoBeacon]
}
