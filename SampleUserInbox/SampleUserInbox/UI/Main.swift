//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import OSLog
import SwiftUI

@main
internal struct Sample: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) internal var appDelegate
    @State private var presentedDeepLink: URL?

    internal var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
            .onOpenURL { url in
                handleUrl(url: url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                guard let url = userActivity.webpageURL else {
                    return
                }

                handleUrl(url: url)
            }
            .banner(item: $presentedDeepLink) { url in
                BannerView(
                    title: String(localized: "main_deep_link_opened_title"),
                    subtitle: url.absoluteString
                )
            }
        }
    }

    private func handleUrl(url: URL) {
        if Actito.shared.handleTestDeviceUrl(url) {
            Logger.main.info("Test device url: \(url.absoluteString).")
            return
        }

        if Actito.shared.handleDynamicLinkUrl(url) {
            Logger.main.info("Dynamic link url: \(url.absoluteString).")
            return
        }

        Logger.main.info("Received deep link: \(url.absoluteString).")
        presentedDeepLink = url
    }
}
