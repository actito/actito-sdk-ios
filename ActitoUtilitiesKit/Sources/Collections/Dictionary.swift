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

    public func compactMapValuesRecursive<T>(_ transform: (Value) throws -> T?) rethrows -> [Key: T] {
        var result: [Key: T] = [:]

        for (key, value) in self {
            if let nested = value as? [Key: Value] {
                let transformed = try nested.compactMapValuesRecursive(transform)
                if !transformed.isEmpty, let casted = transformed as? T {
                    result[key] = casted
                }
            } else if let nested = value as? [Any] {
                let transformed = try nested.compactValuesRecursive { try transform($0 as! Value) }
                if !transformed.isEmpty, let casted = transformed as? T {
                    result[key] = casted
                }
            } else if let transformed = try transform(value) {
                result[key] = transformed
            }
        }

        return result
    }
}
