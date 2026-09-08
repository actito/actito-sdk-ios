//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit
import ActitoGeoKit
import Combine
import Foundation

@MainActor
internal class RegionsViewModel: ObservableObject {
    @Published internal var monitoredRegions: [ActitoRegion] = Actito.shared.geo().monitoredRegions
    @Published internal var enteredRegions: [ActitoRegion] = Actito.shared.geo().enteredRegions

    private var cancellables = Set<AnyCancellable>()

    internal init() {
        NotificationCenter.default
            .publisher(for: .locationUpdated)
            .sink { [weak self] _ in
                self?.monitoredRegions = Actito.shared.geo().monitoredRegions
            }
            .store(in: &cancellables)

        Publishers.Merge(
            NotificationCenter.default.publisher(for: .regionEntered),
            NotificationCenter.default.publisher(for: .regionExited)
        )
            .sink { [weak self] _ in
                self?.enteredRegions = Actito.shared.geo().enteredRegions
            }
            .store(in: &cancellables)
    }
}
