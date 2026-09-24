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
                    Button {
                        LiveActivitiesController.shared.createCoffeeBrewerLiveActivity()
                    } label: {
                        Text(String(localized: "live_activity_grind_button"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.coffeeBrewerLiveActivityState != .none)
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))

                    Button {
                        LiveActivitiesController.shared.continueCoffeeBrewerLiveActivity()
                    } label: {
                        Text(String(localized: "live_activity_brew_button"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.coffeeBrewerLiveActivityState != .grinding)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    Button {
                        LiveActivitiesController.shared.continueCoffeeBrewerLiveActivity()
                    } label: {
                        Text(String(localized: "live_activity_serve_button"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.coffeeBrewerLiveActivityState != .brewing)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    Button {
                        LiveActivitiesController.shared.cancelCoffeeBrewerLiveActivity()
                    } label: {
                        Text(String(localized: "live_activity_cancel_button"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.coffeeBrewerLiveActivityState == .none)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
                }
            } header: {
                HStack {
                    Text(String(localized: "live_activity_coffee_brewer"))
                }
            }
            .listRowSeparator(.hidden)
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
