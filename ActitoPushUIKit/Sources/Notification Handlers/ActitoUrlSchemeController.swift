//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import UIKit

internal class ActitoUrlSchemeController: ActitoNotificationPresenter {
    private let notification: ActitoNotification

    internal init(notification: ActitoNotification) {
        self.notification = notification
    }

    internal func present(in _: UIViewController) {
        guard let content = notification.content.first,
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)
        else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        guard url.host?.hasSuffix("ntc.re") == true else {
            // It's a non-universal link, let's just try and open it.
            presentDeepLink(url)
            return
        }

        Task {
            do {
                // It's an universal link from Actito, let's get the target.
                let link = try await Actito.shared.fetchDynamicLink(urlStr)

                guard let url = URL(string: link.target) else {
                    DispatchQueue.main.async {
                        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
                    }

                    return
                }

                self.presentDeepLink(url)
            } catch {
                DispatchQueue.main.async {
                    Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
                }
            }
        }
    }

    private func presentDeepLink(_ url: URL) {
        guard let urlScheme = url.scheme else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        guard Bundle.main.getSupportedUrlSchemes().contains(urlScheme) else {
            logger.warning("Cannot open a deep link that's not supported by the application.")

            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didPresentNotification: self.notification)
        }

        UIApplication.shared.open(url, options: [:]) { _ in
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
            }
        }
    }
}
