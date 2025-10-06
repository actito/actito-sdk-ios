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

    public func compactNestedValues<T>(_ transform: (Any) throws -> T?) rethrows -> [Any] {
        var result: [Any] = []

        for element in self {
            switch element {
                case is NSNull:
                    continue

                case let nestedArray as [Any]:
                    let nestedValues = try nestedArray.compactNestedValues(transform)
                    result.append(contentsOf: nestedValues)

                case let nestedDict as [String: Any]:
                    let nestedValues = try nestedDict.compactNestedMapValues(transform)
                    result.append(nestedValues)

                default:
                    // Apply transformation to leaf value
                    if let transformed = try transform(element) {
                        result.append(transformed)
                    }
                }
        }

        return result
    }

}
