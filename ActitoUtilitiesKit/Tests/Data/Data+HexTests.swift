//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoUtilitiesKit
import Foundation
import Testing

internal struct DataHexTests {
    @Test
    internal func testDataToHexStringWithSingleByte() {
        let data = Data([0x0F])
        let hexString = data.toHexString()
        #expect(hexString == "0f")
    }

    @Test
    internal func testDataToHexStringWithMultipleBytes() {
        let data = Data([0xFF, 0xA5, 0x10])
        let hexString = data.toHexString()
        #expect(hexString == "ffa510")
    }

    @Test
    internal func testDataToHexStringWithEmptyData() {
        let data = Data()
        let hexString = data.toHexString()
        #expect(hexString == "")
    }
}
