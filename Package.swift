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
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito.zip",
            checksum: "ac99a9bac475205e319abeeb1e656b6c104fdac9bbc923a5b58ed9e4d80187c7"
        ),
        .binaryTarget(
            name: "ActitoAssetsKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-assets.zip",
            checksum: "05fef3701bf891ce8db298b798a5bca88833557659bf9a8d1bf53a04454d8018"
        ),
        .binaryTarget(
            name: "ActitoGeoKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-geo.zip",
            checksum: "7484ed902e4c2aca2f8d088e43b62e1b2d3ac7dc1b44796bf8b51bacc36e1939"
        ),
        .binaryTarget(
            name: "ActitoInAppMessagingKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-in-app-messaging.zip",
            checksum: "be3c5d2a6efdd03e00788cd0cc93a735d6bf75a8098304d9d1506bbf49d95231"
        ),
        .binaryTarget(
            name: "ActitoInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-inbox.zip",
            checksum: "98bf4ec706ae026383b0b68ddc479a4bd59b5b8f98015b3db66587c55ebb3c41"
        ),
        .binaryTarget(
            name: "ActitoLoyaltyKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-loyalty.zip",
            checksum: "6110784fc27836728d905445e2091379a7561d64dc8d11f360d29f6167ce401c"
        ),
        .binaryTarget(
            name: "ActitoPushKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-push.zip",
            checksum: "3ee3db725cdc2aa798f62c1f08819db9cb24d8f101c303daa5549ba0cc8ed3d0"
        ),
        .binaryTarget(
            name: "ActitoNotificationServiceExtensionKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-notification-service-extension.zip",
            checksum: "bef4a7972fc4ecfa69cf422158d4c0b0d3ae3cfadb0abb1721c00105fc2b288b"
        ),
        .binaryTarget(
            name: "ActitoPushUIKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-push-ui.zip",
            checksum: "e3b8d79db9356249b329fdcf9d11e7d062c96298231c825932c59d2f19284b67"
        ),
        .binaryTarget(
            name: "ActitoUserInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-user-inbox.zip",
            checksum: "930a611fc465bc2b90e1060ae0259cf50256652805034ea7c39c8bfe3ca046a3"
        ),
        .binaryTarget(
            name: "ActitoUtilitiesKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.2.0/spm-actito-utilities.zip",
            checksum: "78bd4542708162e443e7ee723f90246ec2959aae445adac278b95cac8682410a"
        ),
    ]
)
