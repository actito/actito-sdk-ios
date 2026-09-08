//
// Copyright (c) 2025 Actito. All rights reserved.
//
import SwiftUI

internal struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    internal var body: some View {
        List {
            LaunchSection()

            if viewModel.viewState == .isReady {
                CoreSection()

                NotificationsSection()

                LocationSection()

                InAppMessagingSection()

                OtherFeaturesSection()
            }
        }
        .navigationTitle(String(localized: "home_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

internal struct HomeView_Previews: PreviewProvider {
    internal static var previews: some View {
        HomeView()
    }
}
