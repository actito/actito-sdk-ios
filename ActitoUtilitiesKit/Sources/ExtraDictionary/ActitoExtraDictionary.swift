//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

@propertyWrapper
public struct ActitoExtraDictionary<Value> {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: ExpressibleByNilLiteral {
        self.wrappedValue = nil
    }
}

extension ActitoExtraDictionary where Value == [String: Any] {
    public init() {
        self.wrappedValue = [:]
    }
}

extension ActitoExtraDictionary: ActitoOptionalCodingWrapper where Value: ExpressibleByNilLiteral {
    public typealias WrappedType = Value
}

extension ActitoExtraDictionary: @unchecked Sendable {}

extension ActitoExtraDictionary: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Non-optional `[String: Any]`
        if Value.self is [String: Any].Type {
            if container.decodeNil() {
                self.wrappedValue = ([:] as [String: Any]) as! Value
                return
            }

            let boxed = try container.decode(ActitoAnyDecodable.self)
            guard let unboxed = boxed.value as? [String: Any] else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode ActitoExtraDictionary.")
            }

            let pruned = prune(unboxed, dropEmptyContainers: true) as? [String: Any] ?? [:]

            self.wrappedValue = pruned as! Value
            return
        }

        // Optional `[String: Any]?`
        if Value.self is Optional<[String: Any]>.Type {
            if container.decodeNil() {
                self.wrappedValue = (nil as [String: Any]?) as! Value
                return
            }

            let boxed = try container.decode(ActitoAnyDecodable.self)
            guard let unboxed = boxed.value as? [String: Any] else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode ActitoExtraDictionary.")
            }

            let pruned = prune(unboxed, dropEmptyContainers: true) as? [String: Any] ?? [:]
            self.wrappedValue = (Optional.some(pruned) as [String: Any]?) as! Value
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unsupported Value type \(Value.self). Expected [String: Any] or [String: Any]?"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        // Non-optional
        if let dict = wrappedValue as? [String: Any] {
            try container.encode(ActitoAnyEncodable(dict))
            return
        }

        // Optional
        if let opt = wrappedValue as? [String: Any]? {
            if let dict = opt {
                try container.encode(ActitoAnyEncodable(dict))
            } else {
                try container.encodeNil()
            }
            return
        }

        throw EncodingError.invalidValue(
            wrappedValue,
            EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "Unsupported Value type \(Value.self). Expected [String: Any] or [String: Any]?"
            )
        )
    }
}

extension ActitoExtraDictionary: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        // Non-optional case
        if
            let l = lhs.wrappedValue as? [String: Any],
            let r = rhs.wrappedValue as? [String: Any]
        {
            return ActitoAnyCodable(l) == ActitoAnyCodable(r)
        }

        // Optional case
        if
            let lOpt = lhs.wrappedValue as? [String: Any]?,
            let rOpt = rhs.wrappedValue as? [String: Any]?
        {
            switch (lOpt, rOpt) {
            case (nil, nil):
                return true
            case let (.some(l), .some(r)):
                return ActitoAnyCodable(l) == ActitoAnyCodable(r)
            default:
                return false
            }
        }

        // Different Value specializations (should not happen)
        return false
    }
}

// MARK: - Auxiliary functions to prune null values

private func prune(_ value: Any, dropEmptyContainers: Bool) -> Any? {
    // Handle any kind of null value.
    if isNull(value) {
        return nil
    }

    // Dictionaries
    if let dict = value as? [String: Any] {
        var out: [String: Any] = [:]
        out.reserveCapacity(dict.count)

        for (k, v) in dict {
            if let pruned = prune(v, dropEmptyContainers: dropEmptyContainers) {
                out[k] = pruned
            }
        }

        return dropEmptyContainers && out.isEmpty ? nil : out
    }

    // Arrays
    if let arr = value as? [Any] {
        let out = arr.compactMap { prune($0, dropEmptyContainers: dropEmptyContainers) }
        return dropEmptyContainers && out.isEmpty ? nil : out
    }

    // Scalar values
    return value
}

private func isNull(_ value: Any) -> Bool {
    if value is NSNull {
        return true
    }

    let m = Mirror(reflecting: value)
    return m.displayStyle == .optional && m.children.isEmpty
}
