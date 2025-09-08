/**
 A type-erased `Codable` value.
 The `ActitoAnyCodable` type forwards encoding and decoding responsibilities
 to an underlying value, hiding its specific underlying type.
 You can encode or decode mixed-type values in dictionaries
 and other collections that require `Encodable` or `Decodable` conformance
 by declaring their contained type to be `ActitoAnyCodable`.
 - SeeAlso: `ActitoAnyEncodable`
 - SeeAlso: `ActitoAnyDecodable`
 */
#if swift(>=5.1)
@frozen public struct ActitoAnyCodable: Codable, @unchecked Sendable {
    public let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}
#else
public struct ActitoAnyCodable: Codable {
    public let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}
#endif

extension ActitoAnyCodable: _ActitoAnyEncodable, _ActitoAnyDecodable {}

extension ActitoAnyCodable: Equatable {
    public static func == (lhs: ActitoAnyCodable, rhs: ActitoAnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (Void, Void):
            return true
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
        case let (lhs as [String: ActitoAnyCodable], rhs as [String: ActitoAnyCodable]):
            return lhs == rhs
        case let (lhs as [ActitoAnyCodable], rhs as [ActitoAnyCodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension ActitoAnyCodable: CustomStringConvertible {
    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}

extension ActitoAnyCodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "ActitoAnyCodable(\(value.debugDescription))"
        default:
            return "ActitoAnyCodable(\(description))"
        }
    }
}

extension ActitoAnyCodable: ExpressibleByNilLiteral {}
extension ActitoAnyCodable: ExpressibleByBooleanLiteral {}
extension ActitoAnyCodable: ExpressibleByIntegerLiteral {}
extension ActitoAnyCodable: ExpressibleByFloatLiteral {}
extension ActitoAnyCodable: ExpressibleByStringLiteral {}
extension ActitoAnyCodable: ExpressibleByArrayLiteral {}
extension ActitoAnyCodable: ExpressibleByDictionaryLiteral {}
