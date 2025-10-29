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
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito.zip",
            checksum: "{{ACTITO_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoAssetsKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-assets.zip",
            checksum: "{{ACTITO_ASSETS_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoGeoKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-geo.zip",
            checksum: "{{ACTITO_GEO_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoInAppMessagingKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-in-app-messaging.zip",
            checksum: "{{ACTITO_IN_APP_MESSAGING_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-inbox.zip",
            checksum: "{{ACTITO_INBOX_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoLoyaltyKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-loyalty.zip",
            checksum: "{{ACTITO_LOYALTY_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoPushKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-push.zip",
            checksum: "{{ACTITO_PUSH_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoNotificationServiceExtensionKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-notification-service-extension.zip",
            checksum: "{{ACTITO_NOTIFICATION_SERVICE_EXTENSION_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoPushUIKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-push-ui.zip",
            checksum: "{{ACTITO_PUSH_UI_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoUserInboxKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-user-inbox.zip",
            checksum: "{{ACTITO_USER_INBOX_CHECKSUM}}"
        ),
        .binaryTarget(
            name: "ActitoUtilitiesKit",
            url: "https://cdn-mobile.actito.com/libs/ios/{{VERSION}}/spm-actito-utilities.zip",
            checksum: "{{ACTITO_UTILITIES_CHECKSUM}}"
        ),
    ]
)
