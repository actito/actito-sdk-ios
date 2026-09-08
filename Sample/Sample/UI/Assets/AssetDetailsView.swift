//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoAssetsKit
import SwiftUI

internal struct AssetDetailsView: View {
    internal let asset: ActitoAsset

    internal var body: some View {
        List {
            Section {
                AssetDetailsFieldView(key: String(localized: "asset_details_id"), value: asset.id)
                AssetDetailsFieldView(key: String(localized: "asset_details_title"), value: asset.title)
                AssetDetailsFieldView(key: String(localized: "asset_details_description"), value: asset.description)
                AssetDetailsFieldView(key: String(localized: "asset_details_key"), value: asset.key)
                AssetDetailsFieldView(key: String(localized: "asset_details_url"), value: asset.url)
                AssetDetailsFieldView(key: String(localized: "asset_details_button"), value: asset.button?.label)
                AssetDetailsFieldView(key: String(localized: "asset_details_action"), value: asset.button?.action)

                if let metaData = asset.metaData {
                    AssetDetailsFieldView(key: String(localized: "asset_details_original_file_name"), value: metaData.originalFileName)
                    AssetDetailsFieldView(key: String(localized: "asset_details_content_type"), value: metaData.contentType)
                    AssetDetailsFieldView(key: String(localized: "asset_details_content_length"), value: String(metaData.contentLength))
                } else {
                    AssetDetailsFieldView(key: String(localized: "asset_details_meta_data"), value: nil)
                }

                if asset.extra.isEmpty {
                    AssetDetailsFieldView(key: String(localized: "asset_details_extras"), value: nil)
                } else {
                    HStack {
                        Text(String(localized: "asset_details_extras"))
                            .fontWeight(.bold)
                    }

                    ForEach(asset.extra.keys.sorted(), id: \.self) { key in
                        AssetDetailsFieldView(key: key, value: String(describing: asset.extra[key]))
                    }
                }
            }
        }
        .navigationTitle(String(localized: "asset_details_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AssetDetailsFieldView: View {
    let key: String
    let value: String?

    var body: some View {
        HStack {
            Text(key)
                .padding(.trailing)

            Spacer()

            Text(value ?? "-")
                .lineLimit(1)
                .truncationMode(.head)
                .foregroundColor(Color.gray)
        }
    }
}

internal struct AssetDetailsView_Previews: PreviewProvider {
    internal static var previews: some View {
        AssetDetailsView(
            asset: ActitoAsset(
                id: "12345",
                title: "Title",
                description: nil,
                key: nil,
                url: nil,
                button: nil,
                metaData: nil,
                extra: [String: Any]()
            )
        )
    }
}
