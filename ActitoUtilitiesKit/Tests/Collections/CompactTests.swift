//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoUtilitiesKit
import Testing
import Foundation

internal struct CompactTests {
    internal struct TestStruct: Equatable {
        @ActitoExtraEquatable internal var extra: [String: Any?]
    }

    internal struct TestArrayStruct: Equatable {
        @ActitoExtraEquatable internal var extra: [Any?]
    }

    @Test
    internal func testCompactSimpleNestedMaps() {
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

    @Test
    internal func testCompactArraysWithNestedMapsAndArrays() {
        let array: [Any] = [
            1,
            2,
            NSNull(),
            ["foo": "bar", "baz": NSNull()],
            3,
            [4, NSNull(), ["nested": 5, "empty": NSNull()]],
            6,
        ]

        let expectedArray: [Any] = [
            1,
            2,
            ["foo": "bar"],
            3,
            [4, ["nested": 5]],
            6,
        ]

        let compactedArray = array.compactNestedValues { $0 is NSNull ? nil : $0 }

        let firstObject = TestArrayStruct(extra: compactedArray)
        let secondObject = TestArrayStruct(extra: expectedArray)

        #expect(firstObject == secondObject)
    }

    @Test
    public func testCompactMapWithNestedMapsAndArrays() throws {
        let dictionary: [String: Any?] = [
            "id": 123,
            "name": "John",
            "age": nil,
            "nickname": NSNull(),
            "details": [
                "age": NSNull(),
                "country": "USA",
                "address": [
                    "city": "New York",
                    "zip": NSNull(),
                ],
            ],
            "preferences": [
                "notifications": [
                    "email": true,
                    "sms": NSNull(),
                ],
                "themes": [
                    ["name": "dark", "active": true],
                    ["name": "light", "active": NSNull()],
                ],
            ],
            "history": [
                [
                    "action": "login",
                    "time": NSNull(),
                ],
                [
                    "action": "logout",
                    "time": "2025-10-06T12:00:00Z",
                ],
            ],
        ]

        let expectedDictionary: [String: Any] = [
            "id": 123,
            "name": "John",
            "details": [
                "country": "USA",
                "address": [
                    "city": "New York"
                ],
            ],
            "preferences": [
                "notifications": [
                    "email": true
                ],
                "themes": [
                    ["name": "dark", "active": true],
                    ["name": "light"],
                ],
            ],
            "history": [
                [
                    "action": "login"
                ],
                [
                    "action": "logout",
                    "time": "2025-10-06T12:00:00Z",
                ],
            ],
        ]

        let compactedDictionary = dictionary.compactNestedMapValues { $0 is NSNull ? nil : $0 }

        let firstObject = TestStruct(extra: compactedDictionary)
        let secondObject = TestStruct(extra: expectedDictionary)

        #expect(firstObject == secondObject)
    }
}
