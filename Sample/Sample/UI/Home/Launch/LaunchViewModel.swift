//
// Copyright (c) 2026 Actito. All rights reserved.
//

import Combine
import Foundation
import ActitoKit
import OSLog

@MainActor
internal class LaunchViewModel: NSObject, ObservableObject {
    @Published internal private(set) var isConfigured = Actito.shared.isConfigured
    @Published internal private(set) var isReady = Actito.shared.isReady

    private var cancellables = Set<AnyCancellable>()

    override internal init() {
        super.init()

        NotificationCenter.default
            .publisher(for: .actitoStatus)
            .sink { [weak self] notification in
                guard let ready = notification.userInfo?["ready"] as? Bool else {
                    return
                }

                self?.isReady = ready
            }
            .store(in: &cancellables)
    }

    internal func actitoLaunch() {
        Logger.main.info("Actito launch clicked")
        Actito.shared.launch { _ in }
    }

    internal func actitoUnlaunch() {
        Logger.main.info("Actito unlaunch clicked")
        Actito.shared.unlaunch { _ in }
    }
}
