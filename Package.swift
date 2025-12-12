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
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito.zip",
            checksum: "fa789e5366dcf51c0bd83daa2d707334fabec1c3e69b7a31bacdffacf98d68e3"
        ),
        .binaryTarget(
            name: "ActitoAssetsKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-assets.zip",
            checksum: "d126a4fef54671f8c19afb127e827f045f98cc4b4d1074466e9208d3b7cc8cd0"
        ),
        .binaryTarget(
            name: "ActitoGeoKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-geo.zip",
            checksum: "1ac4fe8abd57bd506f830f2b25b1c0005edf43bb5a5b625083fee10368dd0376"
        ),
        .binaryTarget(
            name: "ActitoInAppMessagingKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-in-app-messaging.zip",
            checksum: "2c89a4721dbe690357a1333d07b4dfb3a9efef8fc9e93f549b25f4f1c2d672dc"
        ),
        .binaryTarget(
            name: "ActitoInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-inbox.zip",
            checksum: "7d22a086882213f796c29e2645e72edc6c439c204dda755fe829a3fd86708339"
        ),
        .binaryTarget(
            name: "ActitoLoyaltyKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-loyalty.zip",
            checksum: "5fedf2f832b58f7604eee605cc0a132d7e082fe2964080dfde2685088f90c9b1"
        ),
        .binaryTarget(
            name: "ActitoPushKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-push.zip",
            checksum: "02a2f991f513f2733f316549913cfdfb4a1e4bd687aae461740de2bf760017a7"
        ),
        .binaryTarget(
            name: "ActitoNotificationServiceExtensionKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-notification-service-extension.zip",
            checksum: "b677140f622a7004734df73ac7bc79500b6a0b729c3e179c665921d593d33d9c"
        ),
        .binaryTarget(
            name: "ActitoPushUIKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-push-ui.zip",
            checksum: "4c0d808318ca642cce64b7289021f2efcc45a8ced6e6cfb53f0d3c47cb742b53"
        ),
        .binaryTarget(
            name: "ActitoUserInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-user-inbox.zip",
            checksum: "a8075760a827f271a9bc598742fa5a806847f0b9cdae21f42b9a85935b2aadaf"
        ),
        .binaryTarget(
            name: "ActitoUtilitiesKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0-beta.2/spm-actito-utilities.zip",
            checksum: "7186fc2c39e30f9b2e54ba4b095132dd3007a71015ef3b6c4862bc1a97276e5a"
        ),
    ]
)
