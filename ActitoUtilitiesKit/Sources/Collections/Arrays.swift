//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension Array {

    @discardableResult
    public mutating func insertSorted(
        _ element: Element,
        by areInIncreasingOrder: (_ lhs: Element, _ rhs: Element) -> Bool
    ) -> Int {
        let index = firstIndex(where: { areInIncreasingOrder(element, $0) }) ?? count
        insert(element, at: index)

        return index
    }

    public func compactValuesRecursive<T>(_ transform: (Element) throws -> T?) rethrows -> [Element] {
        var result: [Element] = []

        for element in self {
            if let nested = element as? [Element] {
                let transformed = try nested.compactValuesRecursive(transform)
                if !transformed.isEmpty, let casted = transformed as? Element {
                    result.append(casted)
                }
            } else if let nested = element as? [AnyHashable: Element] {
                let transformed = try nested.compactMapValuesRecursive { _, value in
                    return try transform(value) }
                if !transformed.isEmpty, let casted = transformed as? Element {
                    result.append(casted)
                }
            } else if let transformed = try transform(element),
                      let casted = transformed as? Element
            {
                result.append(casted)
            }
        }

        return result
    }
}
