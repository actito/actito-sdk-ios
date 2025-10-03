//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoUtilitiesKit
import Testing
import Foundation

internal struct DictionaryExtensionsTests {
    internal struct TestStruct: Equatable {
        @ActitoExtraEquatable internal var extra: [String: Any?]
    }

    @Test
    internal func testMapKeysWithBasicTransformation() throws {
        let originalDictionary = ["one": 1, "two": 2, "three": 3]

        let transformedDictionary = originalDictionary.mapKeys { key in
            "key_" + key
        }

        #expect(transformedDictionary["key_one"] == 1)
        #expect(transformedDictionary["key_two"] == 2)
        #expect(transformedDictionary["key_three"] == 3)
    }

    @Test
    internal func testMapKeysWithDifferentTypes() throws {
        let originalDictionary = ["apple": 1, "banana": 2]

        let transformedDictionary = originalDictionary.mapKeys { key in
            key.count
        }

        #expect(transformedDictionary[5] == 1)
        #expect(transformedDictionary[6] == 2)
    }

    @Test
    internal func testCompactNestedMaps() {
        @ActitoExtraEquatable var dictionary: [String: Any?] = [
            "foo": "bar",
            "baz": NSNull(),
            "bar": nil,
            "product": [
                "name": NSNull(),
                "price": 100,
                "quantity": nil,
            ],
        ]

        @ActitoExtraEquatable var expectedDictionary: [String: Any] = [
            "foo": "bar",
            "product": [
                "price": 100,
            ],
        ]

        let compactedDictionary = dictionary.compactNestedMapValues { $0 is NSNull ? nil : $0 }

        let firstObject = TestStruct(extra: compactedDictionary)
        let secondObject = TestStruct(extra: expectedDictionary)

        #expect(firstObject == secondObject)
    }
}
