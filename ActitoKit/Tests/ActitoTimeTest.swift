//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

internal struct ActitoTimeTest {
    @Test
    internal func testInvalidActitoTimeInitialization() {
        #expect(throws: (any Error).self) {
            try ActitoTime(hours: -1, minutes: 00)
        }

        #expect(throws: (any Error).self) {
            try ActitoTime(hours: 24, minutes: 00)
        }

        #expect(throws: (any Error).self) {
            try ActitoTime(hours: 21, minutes: -1)
        }

        #expect(throws: (any Error).self) {
            try ActitoTime(hours: 21, minutes: 60)
        }
    }

    @Test
    internal func testInvalidActitoTimeStringInitialization() {
        #expect(throws: (any Error).self) {
            try ActitoTime(string: "21h30")
        }
        #expect(throws: (any Error).self) {
            try ActitoTime(string: ":")
        }
        #expect(throws: (any Error).self) {
            try ActitoTime(string: "21:30:45")
        }
    }

    @Test
    internal func testActitoTimeInitialization() {
        do {
            let time = try ActitoTime(hours: 21, minutes: 30)

            #expect(21 == time.hours)
            #expect(30 == time.minutes)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoTimeStringInitialization() {
        do {
            let time = try ActitoTime(string: "21:30")

            #expect(21 == time.hours)
            #expect(30 == time.minutes)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoTimeFormat() {
        do {
            let time = try ActitoTime(string: "21:30").format()

            #expect("21:30" == time)
        } catch {
            Issue.record()
        }
    }
}
