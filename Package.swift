// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Actito",
    platforms: [
        .iOS(.v15),
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
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito.zip",
            checksum: "c00edfc8406d240d0ff3022cb2b760d1f0f8628a42d6b9fdacc464579aaf3404"
        ),
        .binaryTarget(
            name: "ActitoAssetsKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-assets.zip",
            checksum: "bbb874e57beb29ed30a7840469cef72bf6b97a63a9714584e25c725219491dc0"
        ),
        .binaryTarget(
            name: "ActitoGeoKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-geo.zip",
            checksum: "92ada5e31095a56c863d184d7471d4574ed7e608deb88e09dd8d5170b025c882"
        ),
        .binaryTarget(
            name: "ActitoInAppMessagingKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-in-app-messaging.zip",
            checksum: "f86c60185e0eb024889de9a8db0682436b1f2c2fc933f43df989b76a183db2b8"
        ),
        .binaryTarget(
            name: "ActitoInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-inbox.zip",
            checksum: "db98de7d8c0031445fb015fb5162102af7272b2283cb5a58bb2a9a8f859286a4"
        ),
        .binaryTarget(
            name: "ActitoLoyaltyKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-loyalty.zip",
            checksum: "8c649890b6e3ac6eb1efad58878533ed716cba05a7cc678c5f777a3f4ad0b8fd"
        ),
        .binaryTarget(
            name: "ActitoPushKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-push.zip",
            checksum: "ef2a715c62c913fb37c01cb6d85de76b46dd78b51a74ec28e25714d5a5b929a5"
        ),
        .binaryTarget(
            name: "ActitoNotificationServiceExtensionKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-notification-service-extension.zip",
            checksum: "ab2416e19310e02056479cc908bb2ff32fecab8185141f8fd0c7c565a6d50e0a"
        ),
        .binaryTarget(
            name: "ActitoPushUIKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-push-ui.zip",
            checksum: "c6e039a9175e22abb183dd5d7f6fcad41689978b5a7c01e355b67c1f4d1cdf33"
        ),
        .binaryTarget(
            name: "ActitoUserInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-user-inbox.zip",
            checksum: "ba9c4582e708890279cc624a370dee38bd7b675e52cbae755f1b250839d4c651"
        ),
        .binaryTarget(
            name: "ActitoUtilitiesKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.3.0/spm-actito-utilities.zip",
            checksum: "8b632d1512dc1feb501755034b48203c6934510723456500b1b3abd89a68aca7"
        ),
    ]
)
