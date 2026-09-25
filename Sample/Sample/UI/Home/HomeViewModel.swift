//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Combine
import Foundation

internal class HomeViewModel: ObservableObject {
    @Published internal  private(set) var viewState: ViewState = .isNotReady

    private var cancellables = Set<AnyCancellable>()

    internal init() {
        // Listening for actito ready

        NotificationCenter.default
            .publisher(for: .actitoStatus)
            .sink { [weak self] notification in
                guard let ready = notification.userInfo?["ready"] as? Bool else {
                    return
                }

                self?.viewState = ready ? .isReady : .isNotReady
            }
            .store(in: &cancellables)
    }

    internal enum ViewState {
        case isNotReady
        case isReady
    }
}
