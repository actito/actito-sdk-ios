//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoUtilitiesKit
import Testing

internal struct ActitoExtraValueTests {
    private struct TestStruct: Codable, Equatable {
        @ActitoAnyValue var data: Any
    }

    @Test
    internal func testDecode() throws {
        let json = """
            {
                "data": "string"
            }
            """

        let decoded = try JSONDecoder.actito
            .decode(TestStruct.self, from: json.data(using: .utf8)!)

        let expected = TestStruct(data: "string")

        #expect(decoded == expected)
    }

    @Test
    internal func testDecodeDictionary() throws {
        let json = """
            {
                "data": {
                    "key": "value",
                    "count": 1
                }
            }
            """

        let decoded = try JSONDecoder.actito
            .decode(TestStruct.self, from: json.data(using: .utf8)!)

        let expected = TestStruct(data: [
                "key": "value",
                "count": 1,
            ]
        )

        #expect(decoded == expected)
    }

    @Test
    internal func testDecodeArray() throws {
        let json = """
            {
                "data": [1, "two"]
            }
            """

        let decoded = try JSONDecoder.actito
            .decode(TestStruct.self, from: json.data(using: .utf8)!)

        let expected = TestStruct(data: [1, "two"])

        #expect(decoded == expected)
    }

    @Test
    internal func testDecodeNullBecomesNSNull() throws {
        let json = """
            {
                "data": null
            }
            """

        let decoded = try JSONDecoder.actito
            .decode(TestStruct.self, from: json.data(using: .utf8)!)

        #expect(decoded.data is NSNull)
    }

    @Test
    internal func testEncodeRoundTrip() throws {
        let value: Any = ["a": 1]

        let original = TestStruct(data: value)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder.actito.decode(TestStruct.self, from: data)

        #expect(decoded == original)
    }
}
