//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoUtilitiesKit
import Testing

internal struct ActitoExtraEquatableTest {
    internal struct TestStruct: Equatable {
        @ActitoExtraEquatable internal var extra: Any?
    }

    @Test
    internal func testActitoExtraEquatableInvalidType() {
        let firstObject = TestStruct(extra: Date())
        let secondObject = TestStruct(extra: Date())

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableNils() {
        let firstObject = TestStruct(extra: nil)
        let secondObject = TestStruct(extra: nil)

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableBool() {
        let firstObject = TestStruct(extra: Bool(true))
        let secondObject = TestStruct(extra: Bool(true))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongBool() {
        let firstObject = TestStruct(extra: true)
        let secondObject = TestStruct(extra: false)

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt() {
        let firstObject = TestStruct(extra: Int(5))
        let secondObject = TestStruct(extra: Int(5))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt() {
        let firstObject = TestStruct(extra: Int(5))
        let secondObject = TestStruct(extra: Int(6))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt8() {
        let firstObject = TestStruct(extra: Int8(125))
        let secondObject = TestStruct(extra: Int8(125))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt8() {
        let firstObject = TestStruct(extra: Int8(125))
        let secondObject = TestStruct(extra: Int8(126))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt16() {
        let firstObject = TestStruct(extra: Int16(32765))
        let secondObject = TestStruct(extra: Int16(32765))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt16() {
        let firstObject = TestStruct(extra: Int16(32765))
        let secondObject = TestStruct(extra: Int16(32766))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt32() {
        let firstObject = TestStruct(extra: Int32(2147483645))
        let secondObject = TestStruct(extra: Int32(2147483645))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt32() {
        let firstObject = TestStruct(extra: Int32(2147483645))
        let secondObject = TestStruct(extra: Int32(2147483646))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt64() {
        let firstObject = TestStruct(extra: Int64(9223372036854775805))
        let secondObject = TestStruct(extra: Int64(9223372036854775805))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt64() {
        let firstObject = TestStruct(extra: Int64(9223372036854775805))
        let secondObject = TestStruct(extra: Int64(9223372036854775806))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt() {
        let firstObject = TestStruct(extra: UInt(5))
        let secondObject = TestStruct(extra: UInt(5))

        #expect(firstObject == secondObject)
    }
    @Test
    internal func testActitoExtraEquatableWrongUInt() {
        let firstObject = TestStruct(extra: UInt(5))
        let secondObject = TestStruct(extra: UInt(6))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt8() {
        let firstObject = TestStruct(extra: UInt8(125))
        let secondObject = TestStruct(extra: UInt8(125))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt8() {
        let firstObject = TestStruct(extra: UInt8(125))
        let secondObject = TestStruct(extra: UInt8(126))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt16() {
        let firstObject = TestStruct(extra: UInt16(32765))
        let secondObject = TestStruct(extra: UInt16(32765))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt16() {
        let firstObject = TestStruct(extra: UInt16(32765))
        let secondObject = TestStruct(extra: UInt16(32766))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt32() {
        let firstObject = TestStruct(extra: UInt32(2147483645))
        let secondObject = TestStruct(extra: UInt32(2147483645))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt32() {
        let firstObject = TestStruct(extra: UInt32(2147483645))
        let secondObject = TestStruct(extra: UInt32(2147483646))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt64() {
        let firstObject = TestStruct(extra: UInt64(9223372036854775805))
        let secondObject = TestStruct(extra: UInt64(9223372036854775805))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt64() {
        let firstObject = TestStruct(extra: UInt64(9223372036854775805))
        let secondObject = TestStruct(extra: UInt64(9223372036854775806))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableFloat() {
        let firstObject = TestStruct(extra: Float(3.14))
        let secondObject = TestStruct(extra: Float(3.14))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongFloat() {
        let firstObject = TestStruct(extra: Float(3.14))
        let secondObject = TestStruct(extra: Float(2.71))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableDouble() {
        let firstObject = TestStruct(extra: Double(3.14))
        let secondObject = TestStruct(extra: Double(3.14))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongDouble() {
        let firstObject = TestStruct(extra: Double(3.14))
        let secondObject = TestStruct(extra: Double(2.71))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableString() {
        let firstObject = TestStruct(extra: String("pi"))
        let secondObject = TestStruct(extra: String("pi"))

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongString() {
        let firstObject = TestStruct(extra: String("pi"))
        let secondObject = TestStruct(extra: String("euler"))

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableEmptyArray() {
        let firstObject = TestStruct(extra: [])
        let secondObject = TestStruct(extra: [])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableDiferentSizeArray() {
        let firstObject = TestStruct(extra: ["true", false])
        let secondObject = TestStruct(extra: ["true"])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongTypeArray() {
        let firstObject = TestStruct(extra: [Date(), Date()])
        let secondObject = TestStruct(extra: [Date(), Date()])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableNilsArray() {
        let firstObject = TestStruct(extra: [nil, nil])
        let secondObject = TestStruct(extra: [nil, nil])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableBoolArray() {
        let firstObject = TestStruct(extra: [Bool(true)])
        let secondObject = TestStruct(extra: [Bool(true)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongBoolArray() {
        let firstObject = TestStruct(extra: [Bool(true)])
        let secondObject = TestStruct(extra: [Bool(false)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableIntArray() {
        let firstObject = TestStruct(extra: [Int(5)])
        let secondObject = TestStruct(extra: [Int(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongIntArray() {
        let firstObject = TestStruct(extra: [Int(5)])
        let secondObject = TestStruct(extra: [Int(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt8Array() {
        let firstObject = TestStruct(extra: [Int8(125)])
        let secondObject = TestStruct(extra: [Int8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt8Array() {
        let firstObject = TestStruct(extra: [Int8(125)])
        let secondObject = TestStruct(extra: [Int8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt16Array() {
        let firstObject = TestStruct(extra: [Int16(32765)])
        let secondObject = TestStruct(extra: [Int16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt16Array() {
        let firstObject = TestStruct(extra: [Int16(32765)])
        let secondObject = TestStruct(extra: [Int16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt32Array() {
        let firstObject = TestStruct(extra: [Int32(2147483645)])
        let secondObject = TestStruct(extra: [Int32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt32Array() {
        let firstObject = TestStruct(extra: [Int32(2147483645)])
        let secondObject = TestStruct(extra: [Int32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt64Array() {
        let firstObject = TestStruct(extra: [Int64(9223372036854775805)])
        let secondObject = TestStruct(extra: [Int64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt64Array() {
        let firstObject = TestStruct(extra: [Int64(9223372036854775805)])
        let secondObject = TestStruct(extra: [Int64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUIntArray() {
        let firstObject = TestStruct(extra: [UInt(5)])
        let secondObject = TestStruct(extra: [UInt(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUIntArray() {
        let firstObject = TestStruct(extra: [UInt(5)])
        let secondObject = TestStruct(extra: [UInt(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt8Array() {
        let firstObject = TestStruct(extra: [UInt8(125)])
        let secondObject = TestStruct(extra: [UInt8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt8Array() {
        let firstObject = TestStruct(extra: [UInt8(125)])
        let secondObject = TestStruct(extra: [UInt8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt16Array() {
        let firstObject = TestStruct(extra: [UInt16(32765)])
        let secondObject = TestStruct(extra: [UInt16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt16Array() {
        let firstObject = TestStruct(extra: [UInt16(32765)])
        let secondObject = TestStruct(extra: [UInt16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt32Array() {
        let firstObject = TestStruct(extra: [UInt32(2147483645)])
        let secondObject = TestStruct(extra: [UInt32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt32Array() {
        let firstObject = TestStruct(extra: [UInt32(2147483645)])
        let secondObject = TestStruct(extra: [UInt32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt64Array() {
        let firstObject = TestStruct(extra: [UInt64(9223372036854775805)])
        let secondObject = TestStruct(extra: [UInt64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt64Array() {
        let firstObject = TestStruct(extra: [UInt64(9223372036854775805)])
        let secondObject = TestStruct(extra: [UInt64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableFloatArray() {
        let firstObject = TestStruct(extra: [Float(3.14)])
        let secondObject = TestStruct(extra: [Float(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongFloatArray() {
        let firstObject = TestStruct(extra: [Float(3.14)])
        let secondObject = TestStruct(extra: [Float(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableDoubleArray() {
        let firstObject = TestStruct(extra: [Double(3.14)])
        let secondObject = TestStruct(extra: [Double(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongDoubleArray() {
        let firstObject = TestStruct(extra: [Double(3.14)])
        let secondObject = TestStruct(extra: [Double(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableStringArray() {
        let firstObject = TestStruct(extra: [String("pi")])
        let secondObject = TestStruct(extra: [String("pi")])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongStringArray() {
        let firstObject = TestStruct(extra: [String("pi")])
        let secondObject = TestStruct(extra: [String("euler")])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableMixedArray() {
        let firstObject = TestStruct(extra: [String("pi"), nil, Int(5)])
        let secondObject = TestStruct(extra: [String("pi"), nil, Int(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableEmptyDictionary() {
        let firstObject = TestStruct(extra: [:])
        let secondObject = TestStruct(extra: [:])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableDifferentKeysDictionary() {
        let firstObject = TestStruct(extra: ["key": true])
        let secondObject = TestStruct(extra: ["anotherKey": true])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableDiferentSizeDictionary() {
        let firstObject = TestStruct(extra: ["key": false, "anotherKey": true])
        let secondObject = TestStruct(extra: ["key": false])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongTypeDictionary() {
        let firstObject = TestStruct(extra: ["key": Date()])
        let secondObject = TestStruct(extra: ["key": Date()])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableNilsDictionary() {
        let firstObject = TestStruct(extra: ["key": nil])
        let secondObject = TestStruct(extra: ["key": nil])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableStringBoolDictionary() {
        let firstObject = TestStruct(extra: ["key": Bool(true)])
        let secondObject = TestStruct(extra: ["key": Bool(true)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongBoolDictionary() {
        let firstObject = TestStruct(extra: ["key": Bool(true)])
        let secondObject = TestStruct(extra: ["key": Bool(false)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableIntDictionary() {
        let firstObject = TestStruct(extra: ["key": Int(5)])
        let secondObject = TestStruct(extra: ["key": Int(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongIntDictionary() {
        let firstObject = TestStruct(extra: ["key": Int(5)])
        let secondObject = TestStruct(extra: ["key": Int(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt8Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int8(125)])
        let secondObject = TestStruct(extra: ["key": Int8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt8Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int8(125)])
        let secondObject = TestStruct(extra: ["key": Int8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt16Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int16(32765)])
        let secondObject = TestStruct(extra: ["key": Int16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt16Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int16(32765)])
        let secondObject = TestStruct(extra: ["key": Int16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt32Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int32(2147483645)])
        let secondObject = TestStruct(extra: ["key": Int32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt32Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int32(2147483645)])
        let secondObject = TestStruct(extra: ["key": Int32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableInt64Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int64(9223372036854775805)])
        let secondObject = TestStruct(extra: ["key": Int64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongInt64Dictionary() {
        let firstObject = TestStruct(extra: ["key": Int64(9223372036854775805)])
        let secondObject = TestStruct(extra: ["key": Int64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUIntDictionary() {
        let firstObject = TestStruct(extra: ["key": UInt(5)])
        let secondObject = TestStruct(extra: ["key": UInt(5)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUIntDictionary() {
        let firstObject = TestStruct(extra: ["key": UInt(5)])
        let secondObject = TestStruct(extra: ["key": UInt(6)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt8Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt8(125)])
        let secondObject = TestStruct(extra: ["key": UInt8(125)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt8Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt8(125)])
        let secondObject = TestStruct(extra: ["key": UInt8(126)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt16Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt16(32765)])
        let secondObject = TestStruct(extra: ["key": UInt16(32765)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt16Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt16(32765)])
        let secondObject = TestStruct(extra: ["key": UInt16(32766)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt32Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt32(2147483645)])
        let secondObject = TestStruct(extra: ["key": UInt32(2147483645)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt32Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt32(2147483645)])
        let secondObject = TestStruct(extra: ["key": UInt32(2147483646)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableUInt64Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt64(9223372036854775805)])
        let secondObject = TestStruct(extra: ["key": UInt64(9223372036854775805)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongUInt64Dictionary() {
        let firstObject = TestStruct(extra: ["key": UInt64(9223372036854775805)])
        let secondObject = TestStruct(extra: ["key": UInt64(9223372036854775806)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableFloatDictionary() {
        let firstObject = TestStruct(extra: ["key": Float(3.14)])
        let secondObject = TestStruct(extra: ["key": Float(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongFloatDictionary() {
        let firstObject = TestStruct(extra: ["key": Float(3.14)])
        let secondObject = TestStruct(extra: ["key": Float(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableDoubleDictionary() {
        let firstObject = TestStruct(extra: ["key": Double(3.14)])
        let secondObject = TestStruct(extra: ["key": Double(3.14)])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongDoubleDictionary() {
        let firstObject = TestStruct(extra: ["key": Double(3.14)])
        let secondObject = TestStruct(extra: ["key": Double(2.71)])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableStringDictionary() {
        let firstObject = TestStruct(extra: ["key": String("pi")])
        let secondObject = TestStruct(extra: ["key": String("pi")])

        #expect(firstObject == secondObject)
    }

    @Test
    internal func testActitoExtraEquatableWrongStringDictionary() {
        let firstObject = TestStruct(extra: ["key": String("pi")])
        let secondObject = TestStruct(extra: ["key": String("euler")])

        #expect(firstObject != secondObject)
    }

    @Test
    internal func testActitoExtraEquatableMixedDictionary() {
        let firstObject = TestStruct(extra: ["key": String("pi"), "anotherKey": nil, "yetAnotherKey": Int(5)])
        let secondObject = TestStruct(extra: ["key": String("pi"), "anotherKey": nil, "yetAnotherKey": Int(5)])

        #expect(firstObject == secondObject)
    }
}
