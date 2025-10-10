//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoAssetsKit
@testable import ActitoKit
import Testing

private let TEST_REST_API_HOST = "test.actito.com"
private let TEST_SHORT_LINKS_HOST = "actito.com"
private let TEST_APP_LINKS_HOST = "applinks.actito.com"

@MainActor
internal struct AssetsPushAPIModelsTest {
    @Test
    internal func testAssetToModel() throws {
        configureActito()

        let expectedAsset = ActitoAsset(
            id: "testId",
            title: "testTitle",
            description: "testDescription",
            key: "testKey",
            url: "https://\(TEST_REST_API_HOST)/asset/file/testKey",
            button: ActitoAsset.Button(
                label: "testLabel",
                action: "testAction"
            ),
            metaData: ActitoAsset.MetaData(
                originalFileName: "testOriginalName",
                contentType: "testContentType",
                contentLength: 1
            ),
            extra: ["testExtraKey": "testExtraValue"]
        )

        let jsonStr = """
            {
                "_id": "testId",
                "key": "testKey",
                "title": "testTitle",
                "description": "testDescription",
                "extra": {
                    "testExtraKey": "testExtraValue"
                },
                "button": {
                    "label": "testLabel",
                    "action": "testAction"
                },
                "metaData": {
                    "originalFileName": "testOriginalName",
                    "contentType": "testContentType",
                    "contentLength": 1
                }
            }
            """

        let decoded = try JSONDecoder.actito.decode(ActitoInternals.PushAPI.Models.Asset.self, from: jsonStr.data(using: .utf8)!)

        let asset = decoded.toModel(servicesInfo: Actito.shared.servicesInfo)

        #expect(expectedAsset == asset)
    }

    @Test
    internal func testAssetWithNilPropsToModel() throws {
        let expectedAsset = ActitoAsset(
            id: "testId",
            title: "testTitle",
            description: nil,
            key: nil,
            url: nil,
            button: nil,
            metaData: nil,
            extra: [:]
        )

        let jsonStr = """
            {
                "_id": "testId",
                "key": null,
                "title": "testTitle",
                "description": null,
                "extra": {},
                "button": null,
                "metaData": null
            }
            """

        let decoded = try JSONDecoder.actito.decode(ActitoInternals.PushAPI.Models.Asset.self, from: jsonStr.data(using: .utf8)!)

        let asset = decoded.toModel(servicesInfo: nil)

        #expect(expectedAsset == asset)
    }

    private func configureActito() {
        Actito.shared.configure(
            servicesInfo: ActitoServicesInfo(
                applicationKey: "",
                applicationSecret: "",
                hosts: ActitoServicesInfo.Hosts(
                    restApi: TEST_REST_API_HOST,
                    appLinks: TEST_APP_LINKS_HOST,
                    shortLinks: TEST_SHORT_LINKS_HOST
                )
            ),

            options: ActitoOptions(
                debugLoggingEnabled: true
            )
        )
    }
}
