//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension Dictionary {
    /// Same values, corresponding to `map`ped keys.
    ///
    /// - Parameter transform: Accepts each key of the dictionary as its parameter
    ///   and returns a key for the new dictionary.
    /// - Postcondition: The collection of transformed keys must not contain duplicates.
    public func mapKeys<Transformed>(
        _ transform: (Key) throws -> Transformed
    ) rethrows -> [Transformed: Value] {
        try .init(
            uniqueKeysWithValues: map {
                try (transform($0.key), $0.value)
            }
        )
    }

    public func compactMapValuesRecursive<T>(_ transform: (Key, Value) throws -> T?) rethrows -> [Key: Value] {
        var result: [Key: Value] = [:]

        for (key, value) in self {
            if let nested = value as? [Key: Value] {
                let transformed = try nested.compactMapValuesRecursive(transform)
                if !transformed.isEmpty, let casted = transformed as? Value {
                    result[key] = casted
                }
            } else if let nested = value as? [Value] {
                let transformed = try nested.compactValuesRecursive { element in
                    return try transform(key, element)
                }
                if !transformed.isEmpty, let casted = transformed as? Value {
                    result[key] = casted
                }
            } else if
                let transformed = try transform(key, value),
                let casted = transformed as? Value
            {
                result[key] = casted
            }
        }

        return result
    }
}
