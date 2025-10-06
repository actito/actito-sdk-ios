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

    public func compactNestedValues<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        var result: [T] = []

        for element in self {
            if let nested = element as? [Element] {
                let transformed = try nested.compactNestedValues(transform)
                if !transformed.isEmpty, let casted = transformed as? T {
                    result.append(casted)
                }
            } else if let nested = element as? [String: Any] {
                let transformed = try nested.compactNestedMapValues { try transform($0 as! Element) }
                if !transformed.isEmpty, let casted = transformed as? T {
                    result.append(casted)
                }
            } else if let transformed = try transform(element) {
                result.append(transformed)
            }
        }

        return result
    }
}
