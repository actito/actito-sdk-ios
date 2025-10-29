//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import Foundation

public struct ActitoPass: Codable, Equatable, Sendable {
    public let id: String
    public let type: PassType?
    public let version: Int
    public let passbook: String?
    public let template: String?
    public let serial: String
    public let barcode: String
    public let redeem: Redeem
    public let redeemHistory: [Redemption]
    public let limit: Int
    public let token: String
    @ActitoExtraDictionary public private(set) var data: [String: Any]
    public let date: Date
    // public let googlePaySaveLink: String?

    public init(id: String, type: ActitoPass.PassType?, version: Int, passbook: String?, template: String?, serial: String, barcode: String, redeem: ActitoPass.Redeem, redeemHistory: [ActitoPass.Redemption], limit: Int, token: String, data: [String: Any], date: Date) {
        self.id = id
        self.type = type
        self.version = version
        self.passbook = passbook
        self.template = template
        self.serial = serial
        self.barcode = barcode
        self.redeem = redeem
        self.redeemHistory = redeemHistory
        self.limit = limit
        self.token = token
        self.data = data
        self.date = date
    }

    public enum PassType: String, Codable, Sendable {
        case boarding
        case coupon
        case ticket
        case generic
        case card
    }

    public enum Redeem: String, Codable, Sendable {
        case once
        case limit
        case always
    }

    public struct Redemption: Codable, Equatable, Sendable {
        public let comments: String?
        public let date: Date

        public init(comments: String?, date: Date) {
            self.comments = comments
            self.date = date
        }
    }
}

// Identifiable: ActitoPass
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoPass: Identifiable {}

// JSON: ActitoPass
extension ActitoPass {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoPass {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoPass.self, from: data)
    }
}

// JSON: ActitoPass.Redemption
extension ActitoPass.Redemption {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoPass.Redemption {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoPass.Redemption.self, from: data)
    }
}
