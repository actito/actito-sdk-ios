//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

/// Represents time without a date or time zone.
///
/// ``ActitoTime`` is used for time-based configurations such as do-not-disturb
/// windows. It stores hours and minutes in 24-hour format and enforces valid ranges.
public struct ActitoTime: Equatable, Sendable {
    /// Hour component of the time in 24-hour format.
    ///
    /// Must be between `0` and `23` (inclusive).
    public let hours: Int

    /// Minute component of the time.
    ///
    /// Must be between `0` and `59` (inclusive).
    public let minutes: Int

    /// Constructor for ``ActitoTime`` instance.
    ///
    /// Throws an `ActitoError.invalidArgument` if ``hours`` or ``minutes`` are out of range.
    public init(hours: Int, minutes: Int) throws {
        if 0 ... 23 ~= hours, 0 ... 59 ~= minutes {
            self.hours = hours
            self.minutes = minutes
        } else {
            throw ActitoError.invalidArgument(message: "Invalid time '\(hours):\(minutes)'.")
        }
    }

    /// Creates an ``ActitoTime`` from a `HH:mm` formatted string.
    ///
    /// For example: `"09:30"` or `"18:05"`.
    ///
    /// Throws an `ActitoError.invalidArgument` if the string is not in a valid format
    /// or represents an invalid time.
    public init(string: String) throws {
        let parts = string.components(separatedBy: ":")

        guard parts.count == 2,
              let hours = Int(parts[0]),
              let minutes = Int(parts[1])
        else {
            throw ActitoError.invalidArgument(message: "Invalid time '\(string)'.")
        }

        try self.init(hours: hours, minutes: minutes)
    }

    /// Returns the time formatted as a `HH:mm` string.
    public func format() -> String {
        String(format: "%02d:%02d", locale: Locale(identifier: "en_US"), hours, minutes)
    }
}

extension ActitoTime: Codable {
    /// Decodable confromance for ``ActitoTime``.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        try self.init(string: value)
    }

    /// Encodable conformance for ``ActitoTime``.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(format())
    }
}
