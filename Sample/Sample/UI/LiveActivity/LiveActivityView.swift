//
// Copyright (c) 2026 Actito. All rights reserved.
//

import SwiftUI

internal struct LiveActivityView: View {
    @StateObject private var viewModel = LiveActivityViewModel()
    internal var body: some View {
        List {
            Section {
                if #available(iOS 16.1, *) {
                                        Button(String(localized: "live_activity_grind_button")) {
                        LiveActivitiesController.shared.createCoffeeBrewerLiveActivity()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.coffeeBrewerLiveActivityState != .none)

                    Button(String(localized: "live_activity_brew_button")) {
                        LiveActivitiesController.shared.continueCoffeeBrewerLiveActivity()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.coffeeBrewerLiveActivityState != .grinding)

                    Button(String(localized: "live_activity_serve_button")) {
                        LiveActivitiesController.shared.continueCoffeeBrewerLiveActivity()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.coffeeBrewerLiveActivityState != .brewing)

                    Button(String(localized: "live_activity_cancel_button")) {
                        LiveActivitiesController.shared.cancelCoffeeBrewerLiveActivity()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.coffeeBrewerLiveActivityState == .none)
                }
            } header: {
                HStack {
                    Text(String(localized: "live_activity_coffee_brewer"))
                }
            }
        }
        .navigationTitle(String(localized: "live_activity_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

internal struct LiveActivityViewView_Previews: PreviewProvider {
    internal static var previews: some View {
        LiveActivityView()
    }
}
