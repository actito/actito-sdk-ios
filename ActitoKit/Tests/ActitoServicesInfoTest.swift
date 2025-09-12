//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

internal struct ActitoServicesInfoTests {
    @Test
    internal func testRegexValidation() throws {
        let servicesInfo = ActitoServicesInfo(
            applicationKey: "testKey",
            applicationSecret: "testSecret",
            hosts: ActitoServicesInfo.Hosts(
                restApi: "example.com",
                appLinks: "example.com",
                shortLinks: "example.com"
            )
        )

        #expect(throws: Never.self) {
            try servicesInfo.validate()
        }
    }

    @Test
    internal func testHttpsLinkRegexValidation() throws {
        let servicesInfo = ActitoServicesInfo(
            applicationKey: "testKey",
            applicationSecret: "testSecret",
            hosts: ActitoServicesInfo.Hosts(
                restApi: "https://api.example.com",
                appLinks: "https://api.example.com",
                shortLinks: "https://api.example.com"
            )
        )

        #expect(throws: Never.self) {
            try servicesInfo.validate()
        }
    }

    @Test
    internal func testHttpLinkRegexValidation() throws {
        let servicesInfo = ActitoServicesInfo(
            applicationKey: "testKey",
            applicationSecret: "testSecret",
            hosts: ActitoServicesInfo.Hosts(
                restApi: "http://api.example.com",
                appLinks: "http://api.example.com",
                shortLinks: "http://api.example.com"
            )
        )

        #expect(throws: Never.self) {
            try servicesInfo.validate()
        }
    }

    @Test
    internal func testHttpLinkWithPortRegexValidation() throws {
        let servicesInfo = ActitoServicesInfo(
            applicationKey: "testKey",
            applicationSecret: "testSecret",
            hosts: ActitoServicesInfo.Hosts(
                restApi: "http://localhost:3000",
                appLinks: "http://localhost:3000",
                shortLinks: "http://localhost:3000"
            )
        )

        #expect(throws: Never.self) {
            try servicesInfo.validate()
        }
    }
}
