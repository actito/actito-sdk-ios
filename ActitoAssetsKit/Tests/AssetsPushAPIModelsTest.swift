//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoAssetsKit
@testable import ActitoKit
import Testing

internal struct AssetsPushAPIModelsTest {
    @Test
    @MainActor
    internal func testAssetToModel() {
        let expectedAsset = ActitoAsset(
            id: "testId",
            title: "testTitle",
            description: "testDescription",
            key: "testKey",
            url: nil,
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

        let asset = ActitoInternals.PushAPI.Models.Asset(
            _id: "testId",
            key: "testKey",
            title: "testTitle",
            description: "testDescription",
            extra: ["testExtraKey": "testExtraValue"],
            button: ActitoInternals.PushAPI.Models.Asset.Button(
                label: "testLabel",
                action: "testAction"
            ),
            metaData: ActitoInternals.PushAPI.Models.Asset.MetaData(
                originalFileName: "testOriginalName",
                contentType: "testContentType",
                contentLength: 1
            )
        ).toModel()

        #expect(expectedAsset == asset)
    }

    @Test
    @MainActor
    internal func testAssetWithNilPropsToModel() {
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

        let asset = ActitoInternals.PushAPI.Models.Asset(
            _id: "testId",
            key: nil,
            title: "testTitle",
            description: nil,
            extra: [:],
            button: nil,
            metaData: nil
        ).toModel()

        #expect(expectedAsset == asset)
    }
}
