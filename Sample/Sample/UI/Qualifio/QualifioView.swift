//
// Copyright (c) 2025 Actito. All rights reserved.
//

import QualifioKit
import SwiftUI

internal struct QualifioView: View {
    @StateObject private var viewModel = QualifioViewModel()

    internal var body: some View {
        List {
            Section {
                TextField(String(localized: "qualifio_campaign_placeholder"), text: $viewModel.campaign)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(viewModel.launchState.isLoading)

                Button {
                    viewModel.launchCampaign()
                } label: {
                    Text(String(localized: "qualifio_launch_campaign_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.launchState.isLoading)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                if case .failure = viewModel.launchState {
                    Label {
                        Text(String(localized: "error_message_qualifio_launch_campaign"))
                    } icon: {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .foregroundColor(.red)
                    }
                }
            } header: {
                Text(String(localized: "qualifio_launch_campaign_header"))
            }

            Section {
                if viewModel.isInlineCampaignVisible {
                    QualifioInlineCampaign(campaign: viewModel.inlineCampaign)
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                }

                Button {
                    viewModel.isInlineCampaignVisible.toggle()
                } label: {
                    Text(String(localized: viewModel.isInlineCampaignVisible ? "qualifio_inline_campaign_remove_button" : "qualifio_inline_campaign_add_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                HStack(spacing: 8) {
                    ForEach(viewModel.inlineCampaigns, id: \.self) { campaign in
                        Button {
                            viewModel.loadInlineCampaign(campaign)
                        } label: {
                            Text(String(localized: "qualifio_inline_campaign_load_button", campaign))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            } header: {
                Text(String(localized: "qualifio_inline_campaign_header"))
            }
        }
        .navigationTitle(String(localized: "qualifio_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

internal struct QualifioView_Previews: PreviewProvider {
    internal static var previews: some View {
        NavigationView {
            QualifioView()
        }
    }
}
