//
// Copyright (c) 2025 Actito. All rights reserved.
//

import SwiftUI

internal struct InAppMessagingSection: View {
    @StateObject private var viewModel = InAppMessagingViewModel()

    internal var body: some View {
        Section {
            Toggle(isOn: $viewModel.hasEvaluateContextOn) {
                Label {
                    Text(String(localized: "home_in_app_messaging_evaluate_context"))
                } icon: {
                    ListIconView(
                        icon: "arrow.up.message.fill",
                        foregroundColor: .white,
                        backgroundColor: .red
                    )
                }
            }

            Toggle(isOn: $viewModel.hasSuppressedOn) {
                Label {
                    Text(String(localized: "home_in_app_messaging_suppressed"))
                } icon: {
                    ListIconView(
                        icon: "stopwatch.fill",
                        foregroundColor: .white,
                        backgroundColor: .orange
                    )
                }
            }
            .onChange(of: viewModel.hasSuppressedOn) { enabled in
                viewModel.updateSuppressedIamStatus(enabled: enabled)
            }

        } header: {
            Text(String(localized: "home_in_app_messaging_header"))
        }
    }
}

internal struct InAppMessagingSection_Previews: PreviewProvider {
    internal static var previews: some View {
        List {
            InAppMessagingSection()
        }
    }
}
