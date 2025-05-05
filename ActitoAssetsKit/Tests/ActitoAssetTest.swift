//
// Copyright (c) 2025 Actito. All rights reserved.
//

@testable import ActitoAssetsKit
import Testing

internal struct ActitoAssetTest {
    @Test
    internal func testActitoAssetSerialization() {
        let asset = ActitoAsset(
            id: "testId",
            title: "testTitle",
            description: "testDescription",
            key: "testKey",
            url: "testUrl",
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

        do {
            let convertedAsset = try ActitoAsset.fromJson(json: asset.toJson())

            #expect(asset == convertedAsset)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testActitoAssetSerializationWithNilProps() {
        let asset = ActitoAsset(
            id: "testId",
            title: "testTitle",
            description: nil,
            key: nil,
            url: nil,
            button: nil,
            metaData: nil,
            extra: [:]
        )

        do {
            let convertedAsset = try ActitoAsset.fromJson(json: asset.toJson())

            #expect(asset == convertedAsset)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testButtonSerialization() {
        let button = ActitoAsset.Button(
            label: "testLabel",
            action: "testAction"
        )

        do {
            let convertedButton = try ActitoAsset.Button.fromJson(json: button.toJson())

            #expect(button == convertedButton)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testButtonSerializationWithNilProps() {
        let button = ActitoAsset.Button(
            label: nil,
            action: nil
        )

        do {
            let convertedButton = try ActitoAsset.Button.fromJson(json: button.toJson())

            #expect(button == convertedButton)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testMetaDataSerialization() {
        let metadata = ActitoAsset.MetaData(
            originalFileName: "testOriginalName",
            contentType: "testContentType",
            contentLength: 1
        )

        do {
            let convertedMetadata = try ActitoAsset.MetaData.fromJson(json: metadata.toJson())

            #expect(metadata == convertedMetadata)
        } catch {
            Issue.record()
        }
    }
}
