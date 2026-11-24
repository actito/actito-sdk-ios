//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import StoreKit

internal class ActitoStoreController: NSObject, ActitoNotificationPresenter {
    private let notification: ActitoNotification

    internal init(notification: ActitoNotification) {
        self.notification = notification
    }

    internal func present(in controller: UIViewController) {
        guard let content = notification.content.first, content.type == "re.notifica.content.AppStore" else {
            Task { @MainActor in
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        guard let data = content.data as? [String: Any], let identifier = data["identifier"] else {
            Task { @MainActor in
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        let storeController = SKStoreProductViewController()
        storeController.delegate = self

        var parameters: [String: Any] = [SKStoreProductParameterITunesItemIdentifier: identifier]

        if let token = data["campaignToken"] {
            parameters[SKStoreProductParameterCampaignToken] = token
        }

        if let token = data["providerToken"] {
            parameters[SKStoreProductParameterProviderToken] = token
        }

        if let token = data["affiliateToken"] {
            parameters[SKStoreProductParameterAffiliateToken] = token
        }

        if let token = data["advertisingPartnerToken"] {
            parameters[SKStoreProductParameterAdvertisingPartnerToken] = token
        }

        storeController.loadProduct(withParameters: parameters) { success, error in
            Task { @MainActor in
                if !success || error != nil {
                    Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
                } else {
                    Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didPresentNotification: self.notification)
                }
            }
        }

        controller.presentOrPush(storeController)
    }
}

extension ActitoStoreController: SKStoreProductViewControllerDelegate {
    public func productViewControllerDidFinish(_: SKStoreProductViewController) {
        UIApplication.shared.rootViewController?.dismiss(animated: true, completion: {
            Task { @MainActor in
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
            }
        })
    }
}
