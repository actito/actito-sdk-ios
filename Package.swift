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
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito.zip",
            checksum: "cc940d708d254a066ceee899d3186afa89ec2cc577f0a03fbda6caddd4923f4f"
        ),
        .binaryTarget(
            name: "ActitoAssetsKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-assets.zip",
            checksum: "f1a86f1aabf20c6f8a50876a1f93945e1eeaf34c80c1d85617379ca719db0037"
        ),
        .binaryTarget(
            name: "ActitoGeoKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-geo.zip",
            checksum: "50664715feabe0a85752e1097e8632dd103c03c01b0c1772ae681de1c1e5d64e"
        ),
        .binaryTarget(
            name: "ActitoInAppMessagingKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-in-app-messaging.zip",
            checksum: "744381e55b6029425765d11ae1e06bf6a861c1d832c0bcf2da7aaf672fa38be0"
        ),
        .binaryTarget(
            name: "ActitoInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-inbox.zip",
            checksum: "cb58cf2017c95d7562021748f71035a4b47b11c4234c622eb7221b6b0f83db01"
        ),
        .binaryTarget(
            name: "ActitoLoyaltyKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-loyalty.zip",
            checksum: "ca951ec2dca375cbdb3985c72bb08556cf8438bc5af908634cc6b37d77cb4290"
        ),
        .binaryTarget(
            name: "ActitoPushKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-push.zip",
            checksum: "456daec3f61bd159e6930b3c846508d614b630666473a59327980852359ddc49"
        ),
        .binaryTarget(
            name: "ActitoNotificationServiceExtensionKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-notification-service-extension.zip",
            checksum: "fd426a68f4afac5d128642d28a9c2d13308bccf6f3442e881f6a83d3c4b556dd"
        ),
        .binaryTarget(
            name: "ActitoPushUIKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-push-ui.zip",
            checksum: "ab51b5c83f20ad442a80ab593612303957d15e8bf63810aa1aa32561218ab4f2"
        ),
        .binaryTarget(
            name: "ActitoUserInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-user-inbox.zip",
            checksum: "094979a2fa535096d2a9535a3cdb0a796611cd0b067e0746215339ec081a65ec"
        ),
        .binaryTarget(
            name: "ActitoUtilitiesKit",
            url: "https://cdn-mobile.actito.com/libs/ios/5.0.0/spm-actito-utilities.zip",
            checksum: "b238c1f68e2571d83e64e9c15bc32d6f01461ea70c6ffadb2353abcd61207d3d"
        ),
    ]
)
