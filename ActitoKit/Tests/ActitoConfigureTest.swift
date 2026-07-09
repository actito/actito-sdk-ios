//
// Copyright (c) 2026 Actito. All rights reserved.
//

@testable import ActitoKit
import Testing

@MainActor
internal struct ActitoConfigureTest {
    /*
    @Test("configure with missing credentials")
    internal func configureWithMissingCredentials() {
        #expect(processExitsWith: .failure) {
            Actito.shared.configure(
                servicesInfo: ActitoServicesInfo(
                    applicationKey: "key",
                    applicationSecret: ""
                ),
                options: nil
            )
        }

        #expect(processExitsWith: .failure) {
            Actito.shared.configure(
                servicesInfo: ActitoServicesInfo(
                    applicationKey: "",
                    applicationSecret: "secret"
                ),
                options: nil
            )
        }

        #expect(processExitsWith: .failure) {
            Actito.shared.configure(
                servicesInfo: ActitoServicesInfo(
                    applicationKey: "",
                    applicationSecret: ""
                ),
                options: nil
            )
        }
    }

    @Test("configure with invalid hosts")
    internal func configureWithInvalidHosts() {
        #expect(processExitsWith: .failure) {
            Actito.shared.configure(
                servicesInfo: ActitoServicesInfo(
                    applicationKey: "key",
                    applicationSecret: "secret",
                    hosts: ActitoServicesInfo.Hosts(
                        restApi: "htttps://",
                        appLinks: "actito.com",
                        shortLinks: "actito.com/test",
                    )
                ),
                options: nil
            )
        }

        #expect(processExitsWith: .failure) {
            Actito.shared.configure(
                servicesInfo: ActitoServicesInfo(
                    applicationKey: "key",
                    applicationSecret: "secret",
                    hosts: ActitoServicesInfo.Hosts(
                        restApi: "https://",
                        appLinks: "actito.com&",
                        shortLinks: "actito.com/test",
                    )
                ),
                options: nil
            )
        }

        #expect(processExitsWith: .failure) {
            Actito.shared.configure(
                servicesInfo: ActitoServicesInfo(
                    applicationKey: "key",
                    applicationSecret: "secret",
                    hosts: ActitoServicesInfo.Hosts(
                        restApi: "https://",
                        appLinks: "actito.com",
                        shortLinks: "actito.com/_test",
                    )
                ),
                options: nil
            )
        }
    }*/

    @Test("configure ensure properties are initiated")
    internal func configureEnsurePropertiesAreInitiated() {
        Actito.shared.configure(
            servicesInfo: ActitoServicesInfo(
                applicationKey: "key",
                applicationSecret: "secret",
            ),
        )

        #expect(Actito.shared.options != nil)
        #expect(Actito.shared.state == ActitoLaunchState.configured)
    }
}
