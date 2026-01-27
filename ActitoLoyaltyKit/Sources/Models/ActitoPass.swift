//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import Foundation

/// Represents a digital pass issued by Actito.
///
/// An ``ActitoPass`` can be used for loyalty programs, coupons, tickets, or other
/// redeemable items. It includes metadata, redemption history, and optional
/// integrations with mobile wallets like Apple Wallet or Google Pay.
public struct ActitoPass: Codable, Equatable, Sendable {
    /// Unique identifier of the pass.
    public let id: String

    /// Optional type of the pass.
    public let type: PassType?

    /// Version of the pass.
    public let version: Int

    /// Optional Apple Wallet passbook URL or identifier.
    public let passbook: String?

    /// Optional template identifier used to generate the pass.
    public let template: String?

    /// Serial number of the pass.
    public let serial: String

    /// Barcode value associated with the pass.
    public let barcode: String

    /// Redemption behavior of the pass.
    public let redeem: Redeem

    /// History of past redemptions for this pass.
    public let redeemHistory: [Redemption]

    /// Maximum number of times the pass can be redeemed.
    public let limit: Int

    /// Token associated with the pass for secure validation.
    public let token: String

    /// Additional custom data associated with the pass.
    @ActitoExtraDictionary public private(set) var data: [String: Any]

    /// Timestamp indicating when the pass was created or issued.
    public let date: Date
    // public let googlePaySaveLink: String?

    /// Constructor for ``ActitoPass``.
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

    /// Supported pass types.
    public enum PassType: String, Codable, Sendable {
        /// Boarding pass, typically used for flights or transportation.
        case boarding

        /// Coupon pass, used for discounts or promotional offers.
        case coupon

        /// Ticket pass, such as for events or reservations.
        case ticket

        /// Generic pass with no predefined structure.
        case generic

        /// Card-style pass, commonly used for loyalty or membership cards.
        case card
    }

    /// Defines how a pass or offer can be redeemed by a user.
    public enum Redeem: String, Codable, Sendable {
        /// The pass can be redeemed only once.
        case once

        /// The pass can be redeemed a limited number of times.
        case limit

        /// The pass can be redeemed an unlimited number of times.
        case always
    }

    /// Represents a single redemption record for an Actito pass.
    ///
    /// Each ``Redemption`` records the time and optional comments when a pass was redeemed.
    public struct Redemption: Codable, Equatable, Sendable {
        /// Optional comments associated with the redemption.
        public let comments: String?

        /// Timestamp when the pass was redeemed.
        public let date: Date

        /// Constructor for ``Redemption``.
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
    /// Serializes ``ActitoPass`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoPass`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito pass.
    ///
    /// - Returns: A parsed ``ActitoPass`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoPass {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoPass.self, from: data)
    }
}

// JSON: ActitoPass.Redemption
extension ActitoPass.Redemption {
    /// Serializes ``Redemption`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``Redemption`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the redemption.
    ///
    /// - Returns: A parsed ``Redemption`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoPass.Redemption {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoPass.Redemption.self, from: data)
    }
}
