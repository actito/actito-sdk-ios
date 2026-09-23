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
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(uiColor: .separator))
                    )

                Button {
                    viewModel.fetchAssets()
                } label: {
                    Text(String(localized: "assets_search_button"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isSearchAllowed)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
            } header: {
                Text(String(localized: "assets_header"))
            }
            .listRowSeparator(.hidden)

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
