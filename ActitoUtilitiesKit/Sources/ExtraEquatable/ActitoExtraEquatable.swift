//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

@propertyWrapper
public struct ActitoExtraEquatable<T>: Equatable, @unchecked Sendable {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public static func == (lhs: ActitoExtraEquatable<T>, rhs: ActitoExtraEquatable<T>) -> Bool {
        let lhsOptional = lhs.wrappedValue as Any
        let rhsOptional = rhs.wrappedValue as Any

        if case (Optional<Any>.none, Optional<Any>.none) = (lhsOptional, rhsOptional)
        {
            return true
        }

        switch (lhs.wrappedValue, rhs.wrappedValue) {
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [Any], rhs as [Any]):
            if lhs.isEmpty, rhs.isEmpty {
                return true
            }

            guard lhs.count == rhs.count else {
                return false
            }

            for (lhsValue, rhsValue) in zip(lhs, rhs) {
                let lhsEquatable = ActitoExtraEquatable<Any>(wrappedValue: lhsValue)
                let rhsEquatable = ActitoExtraEquatable<Any>(wrappedValue: rhsValue)

                guard lhsEquatable == rhsEquatable else {
                    return false
                }
            }

            return true
        case let (lhs as [String: Any], rhs as [String: Any]):
            if lhs.isEmpty, rhs.isEmpty {
                return true
            }

            guard lhs.count == rhs.count else {
                return false
            }

            for (lhsKey, lhsValue) in lhs {
                guard let rhsValue = rhs[lhsKey] else {
                    return false
                }

                let lhsEquatable = ActitoExtraEquatable<Any>(wrappedValue: lhsValue)
                let rhsEquatable = ActitoExtraEquatable<Any>(wrappedValue: rhsValue)

                guard lhsEquatable == rhsEquatable else {
                    return false
                }
            }

            return true
        default:
            logger.warning("Unable to compare types provided.")
            return false
        }
    }
}
