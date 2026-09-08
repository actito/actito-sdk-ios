//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoAssetsKit
import SwiftUI

internal struct AssetsView: View {
    @StateObject private var viewModel = AssetsViewModel()

    internal var body: some View {
        List {
            Section {
                TextField(String(localized: "assets_group_input"), text: $viewModel.assetsGroup)
                    .disabled(viewModel.viewState.isLoading)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

                Button(String(localized: "assets_search_button")) {
                    viewModel.fetchAssets()
                }
                .frame(maxWidth: .infinity)
                .disabled(!viewModel.isSearchAllowed)
            } header: {
                Text(String(localized: "assets_header"))
            }

            switch viewModel.viewState {
            case .idle:
                EmptyView()

            case .loading:
                ZStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)

            case let .success(assets):
                SearchResultView(assets: assets)

            case .failure:
                ZStack {
                    Label {
                        Text(String(localized: "error_message_assets_fetch"))
                    } icon: {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle(String(localized: "assets_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SearchResultView: View {
    let assets: [ActitoAsset]

    var body: some View {
        Section {
            if assets.isEmpty {
                Label(String(localized: "assets_not_found"), systemImage: "info.circle.fill")
            } else {
                ForEach(assets) { asset in
                    NavigationLink {
                        AssetDetailsView(asset: asset)
                    } label: {
                        AssetItemView(asset: asset)
                    }
                }
            }
        } header: {
            Text(String(localized: "assets_result_header"))
        }
    }
}

internal struct AssetsView_Previews: PreviewProvider {
    internal static var previews: some View {
        AssetsView()
    }
}
