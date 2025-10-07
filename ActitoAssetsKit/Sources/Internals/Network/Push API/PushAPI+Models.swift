//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit

extension ActitoInternals.PushAPI.Models {
    internal struct Asset: Decodable, Equatable, Sendable {
        internal let _id: String
        internal let key: String?
        internal let title: String
        internal let description: String?
        internal let extra: ActitoAnyCodable?
        internal let button: Button?
        internal let metaData: MetaData?

        internal struct Button: Decodable, Equatable {
            internal let label: String?
            internal let action: String?
        }

        internal struct MetaData: Decodable, Equatable {
            internal let originalFileName: String
            internal let contentType: String
            internal let contentLength: Int
        }

        internal func toModel(servicesInfo: ActitoServicesInfo?) -> ActitoAsset {
            let url: String?
            if let key = key, let host = servicesInfo?.hosts.restApi {
                url = "\(host)/asset/file/\(key)"
            } else {
                url = nil
            }

            return ActitoAsset(
                id: _id,
                title: title,
                description: description,
                key: key,
                url: url,
                button: button.map {
                    ActitoAsset.Button(
                        label: $0.label,
                        action: $0.action
                    )
                },
                metaData: metaData.map {
                    ActitoAsset.MetaData(
                        originalFileName: $0.originalFileName,
                        contentType: $0.contentType,
                        contentLength: $0.contentLength
                    )
                },
                extra: (extra?.value as? [String: Any])?.compactMapValuesRecursive {_, value in
                    value is NSNull ? nil : value } ?? [:]
            )
        }
    }
}
