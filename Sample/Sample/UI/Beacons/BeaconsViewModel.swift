//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Combine
import Foundation
import ActitoGeoKit
import SwiftUI

internal class BeaconsViewModel: ObservableObject {
    @Published internal var rangedBeacons = [ActitoBeacon]()

    private var cancellables = Set<AnyCancellable>()

    internal init() {
        observeRangedBeacons()
    }

    private func observeRangedBeacons() {
        NotificationCenter.default.publisher(for: .beaconsRanged)
            .sink { [weak self] notification in
                guard let beacons = notification.userInfo?["beacons"] as? [ActitoBeacon] else {
                    return
                }

                self?.rangedBeacons = beacons
            }
            .store(in: &cancellables)
    }
}
