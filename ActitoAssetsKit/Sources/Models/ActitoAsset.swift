//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

public struct ActitoAsset: Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let description: String?
    public let key: String?
    public let url: String?
    public let button: Button?
    public let metaData: MetaData?
    @ActitoExtraDictionary public private(set) var extra: [String: Any]

    public init(id: String, title: String, description: String?, key: String?, url: String?, button: ActitoAsset.Button?, metaData: ActitoAsset.MetaData?, extra: [String: Any]) {
        self.id = id
        self.title = title
        self.description = description
        self.key = key
        self.url = url
        self.button = button
        self.metaData = metaData
        self.extra = extra
    }

    public struct Button: Codable, Equatable, Sendable {
        public let label: String?
        public let action: String?

        public init(label: String?, action: String?) {
            self.label = label
            self.action = action
        }
    }

    public struct MetaData: Codable, Equatable, Sendable {
        public let originalFileName: String
        public let contentType: String
        public let contentLength: Int

        public init(originalFileName: String, contentType: String, contentLength: Int) {
            self.originalFileName = originalFileName
            self.contentType = contentType
            self.contentLength = contentLength
        }
    }
}

// Identifiable: ActitoAsset
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoAsset: Identifiable {}

// JSON: ActitoAsset
extension ActitoAsset {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoAsset {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoAsset.self, from: data)
    }
}

// JSON: ActitoAsset.Button
extension ActitoAsset.Button {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoAsset.Button {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoAsset.Button.self, from: data)
    }
}

// JSON: ActitoAsset.MetaData
extension ActitoAsset.MetaData {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoAsset.MetaData {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoAsset.MetaData.self, from: data)
    }
}
