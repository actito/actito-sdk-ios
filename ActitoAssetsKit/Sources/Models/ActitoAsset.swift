//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

/// Represents a rich asset returned by Actito.
///
/// An ``ActitoAsset`` contains displayable content such as a title,
/// optional descriptive text, a link to a binary file, and elements like a button
/// or metadata. Additional fields are stored in ``extra``.
public struct ActitoAsset: Codable, Equatable, Sendable {
    /// The ID of the asset
    public let id: String

    /// The title of the asset.
    public let title: String

    /// Optional description of the asset.
    public let description: String?

    /// Optional key of the asset.
    public let key: String?

    /// Optional binary file url of the asset.
    public let url: String?

    /// Optional button associated with the asset.
    public let button: Button?

    /// Optional metadata associated with the asset.
    public let metaData: MetaData?

    /// Collection of key-value pairs used to add extra information to the asset.
    @ActitoExtraDictionary public private(set) var extra: [String: Any]

    /// Constructor for ``ActitoAsset``.
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

    /// Represents a call-to-action button associated with an ``ActitoAsset``.
    public struct Button: Codable, Equatable, Sendable {
        /// Optional text displayed on the button.
        public let label: String?

        /// Optional action associated with the button.
        public let action: String?

        /// Constructor for ``Button``.
        public init(label: String?, action: String?) {
            self.label = label
            self.action = action
        }
    }

    /// Contains metadata describing the underlying file of an ``ActitoAsset``.
    public struct MetaData: Codable, Equatable, Sendable {
        /// The original name of the file as provided at upload time.
        public let originalFileName: String

        /// The MIME type of the file.
        public let contentType: String

        /// The size of the file in bytes.
        public let contentLength: Int

        /// Constructor for ``MetaData``.
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
    /// Serializes ``ActitoAsset`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoAsset`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito asset.
    ///
    /// - Returns: A parsed ``ActitoAsset`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoAsset {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoAsset.self, from: data)
    }
}

// JSON: ActitoAsset.Button
extension ActitoAsset.Button {
    /// Serializes ``Button`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``Button`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the button.
    ///
    /// - Returns: A parsed ``Button`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoAsset.Button {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoAsset.Button.self, from: data)
    }
}

// JSON: ActitoAsset.MetaData
extension ActitoAsset.MetaData {
    /// Serializes ``MetaData`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``MetaData`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the metadata.
    ///
    /// - Returns: A parsed ``MetaData`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoAsset.MetaData {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoAsset.MetaData.self, from: data)
    }
}
