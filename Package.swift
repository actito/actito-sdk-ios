// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Actito",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "ActitoKit",
            targets: ["ActitoKit", "ActitoUtilitiesKit"]
        ),
        .library(
            name: "ActitoAssetsKit",
            targets: ["ActitoAssetsKit", "ActitoUtilitiesKit"]
        ),
        .library(
            name: "ActitoGeoKit",
            targets: ["ActitoGeoKit", "ActitoUtilitiesKit"]
        ),
        .library(
            name: "ActitoInAppMessagingKit",
            targets: ["ActitoInAppMessagingKit", "ActitoUtilitiesKit"]
        ),
        .library(
            name: "ActitoInboxKit",
            targets: ["ActitoInboxKit", "ActitoUtilitiesKit"]
        ),
        .library(
            name: "ActitoLoyaltyKit",
            targets: ["ActitoLoyaltyKit", "ActitoUtilitiesKit"]
        ),
        .library(
            name: "ActitoNotificationServiceExtensionKit",
            targets: ["ActitoNotificationServiceExtensionKit"]
        ),
        .library(
            name: "ActitoPushKit",
            targets: ["ActitoPushKit", "ActitoUtilitiesKit"]
        ),
        .library(
            name: "ActitoPushUIKit",
            targets: ["ActitoPushUIKit", "ActitoUtilitiesKit"]
        ),
        .library(
            name: "ActitoUserInboxKit",
            targets: ["ActitoUserInboxKit", "ActitoUtilitiesKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "ActitoKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito.zip",
            checksum: "05ae14aac131503ef859dced69cd89e3c813e9551c904c623fe7da95670a400e"
        ),
        .binaryTarget(
            name: "ActitoAssetsKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-assets.zip",
            checksum: "5673997e27c7f4f0d28cbf5f09227243eb0e0e9268744569797fccb2dd1a94f8"
        ),
        .binaryTarget(
            name: "ActitoGeoKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-geo.zip",
            checksum: "0d51d8bbca7a09da040bdbeb180371c6c88a894c375523f59e35192ae7342e4f"
        ),
        .binaryTarget(
            name: "ActitoInAppMessagingKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-in-app-messaging.zip",
            checksum: "be8c69d97c24867b3bc54492393c34476a9b16a3d0ec3b0fcc489d1085dbdb16"
        ),
        .binaryTarget(
            name: "ActitoInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-inbox.zip",
            checksum: "12369618b9818962b95e2eabeed7f62523d63d079fbbcfe7db8795f7a5664035"
        ),
        .binaryTarget(
            name: "ActitoLoyaltyKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-loyalty.zip",
            checksum: "8978d7383ab29a07ce55e6450a6cd3d4200290c5df67654dfa246ed0288b76ca"
        ),
        .binaryTarget(
            name: "ActitoPushKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-push.zip",
            checksum: "898c5834d27386eef4da9eaba64f16afe8516c110646e42e18a3e20807ed970c"
        ),
        .binaryTarget(
            name: "ActitoNotificationServiceExtensionKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-notification-service-extension.zip",
            checksum: "75f7a90291e3e5745e33a4ee7987e64d775c0a464c18a63dda175e99fac8d659"
        ),
        .binaryTarget(
            name: "ActitoPushUIKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-push-ui.zip",
            checksum: "437eb480193342bca4378e0bc9b801a2ab51760ea75f461bcc7ead6c93d96572"
        ),
        .binaryTarget(
            name: "ActitoUserInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-user-inbox.zip",
            checksum: "0942460bd0203df309836244475d84446e930481acde3ca66a8e2780b29a2268"
        ),
        .binaryTarget(
            name: "ActitoUtilitiesKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.1/spm-actito-utilities.zip",
            checksum: "e80540a3960cea1bc38e45cf12b9f5dbe09965f26800b21903c6c9452c46a582"
        ),
    ]
)
