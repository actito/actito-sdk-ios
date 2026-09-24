//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActivityKit
import Foundation
import OSLog
import SwiftUI

@MainActor
internal class LiveActivityViewModel: ObservableObject {
    @Published internal private(set) var coffeeBrewerLiveActivityState: CoffeeBrewerActivityAttributes.BrewingState?

    internal init() {
        if #available(iOS 16.1, *), LiveActivitiesController.shared.hasLiveActivityCapabilities {
            monitorLiveActivities()
        }
    }

    @available(iOS 16.1, *)
    private func monitorLiveActivities() {
        withAnimation {
            // Load the initial state.
            coffeeBrewerLiveActivityState = Activity<CoffeeBrewerActivityAttributes>.activities.first?.contentState.state
        }

        Task {
            // Listen to on-going and new Live Activities.
            for await activity in Activity<CoffeeBrewerActivityAttributes>.activityUpdates {
                Task {
                    // Listen to state changes of each activity.
                    for await state in activity.activityStateUpdates {
                        Logger.main.debug("Live activity '\(activity.id)' state = '\(String(describing: state))'")

                        switch activity.activityState {
                        case .active:
                            Task {
                                // Listen to content updates of each active activity.
                                for await state in activity.contentStateUpdates {
                                    withAnimation {
                                        coffeeBrewerLiveActivityState = state.state
                                    }
                                }
                            }

                        case .dismissed, .ended:
                            // Reset the UI controls.
                            coffeeBrewerLiveActivityState = nil

                        case .stale:
                            break

                        @unknown default:
                            Logger.main.warning("Live activity '\(activity.id)' unknown state '\(String(describing: state))'.")
                        }
                    }
                }
            }
        }
    }
}
