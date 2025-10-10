//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoUtilitiesKit
import Testing

internal struct ExtraDictionaryTests {
    private struct TestStruct: Codable, Equatable {
        @ActitoExtraDictionary var extra: [String: Any] = [:]
    }

    private struct TestStructWithOptionalExtra: Codable, Equatable {
        @ActitoExtraDictionary var extra: [String: Any]? = nil
    }

    @Test
    internal func testBasicExtra() throws {
        let jsonStr = """
            {
                "extra": {
                    "name": "John Doe",
                    "age": 30,
                    "hobbies": ["snowboarding"],
                    "children": [
                        {
                            "name": "John Doe Jr."
                        },
                        {
                            "name": "Jane Doe"
                        }
                    ],
                    "favouriteColours": {
                        "red": "#FF0000",
                        "blue": "#0000FF"
                    }
                }
            }
            """

        let expected = TestStruct(
            extra: [
                "name": "John Doe",
                "age": 30,
                "hobbies": ["snowboarding"],
                "children": [
                    [ "name": "John Doe Jr." ],
                    [ "name": "Jane Doe" ],
                ],
                "favouriteColours": [
                    "red": "#FF0000",
                    "blue": "#0000FF",
                ],
            ]
        )

        let decoded = try JSONDecoder.actito.decode(TestStruct.self, from: jsonStr.data(using: .utf8)!)

        #expect(decoded == expected)
    }

    @Test
    internal func testExtraWithNullValues() throws {
        let jsonStr = """
            {
                "extra": {
                    "name": "John Doe",
                    "surname": null,
                    "age": 30,
                    "hobbies": ["snowboarding", null],
                    "children": [
                        {
                            "name": "John Doe Jr."
                        },
                        null,
                        {
                            "name": "Jane Doe"
                        }
                    ],
                    "favouriteColours": {
                        "red": "#FF0000",
                        "blue": "#0000FF",
                        "yellow": null
                    }
                }
            }
            """

        let expected = TestStruct(
            extra: [
                "name": "John Doe",
                "age": 30,
                "hobbies": ["snowboarding"],
                "children": [
                    [ "name": "John Doe Jr." ],
                    [ "name": "Jane Doe" ],
                ],
                "favouriteColours": [
                    "red": "#FF0000",
                    "blue": "#0000FF",
                ],
            ]
        )

        let decoded = try JSONDecoder.actito.decode(TestStruct.self, from: jsonStr.data(using: .utf8)!)

        #expect(decoded == expected)
    }

    @Test
    internal func testUndefinedExtra() throws {
        let jsonStr = "{}"

        let expected = TestStructWithOptionalExtra(
            extra: nil
        )

        let decoded = try JSONDecoder.actito.decode(TestStructWithOptionalExtra.self, from: jsonStr.data(using: .utf8)!)

        #expect(decoded == expected)
    }

    @Test
    internal func testNullExtra() throws {
        let jsonStr = """
        {
            "extra": null
        }
        """

        let expected = TestStruct(
            extra: [:]
        )

        let decoded = try JSONDecoder.actito.decode(TestStruct.self, from: jsonStr.data(using: .utf8)!)

        #expect(decoded == expected)
    }
}
