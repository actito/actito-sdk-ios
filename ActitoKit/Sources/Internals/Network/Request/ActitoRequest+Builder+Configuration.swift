//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import UIKit

extension ActitoRequest.Builder {
    public convenience init() {
        self.init(
            userAgent: UIDevice.current.userAgent(sdkVersion: Actito.SDK_VERSION),
            preferredLanguage: Actito.shared.device().preferredLanguage,
            restApi: Actito.shared.servicesInfo?.hosts.restApi,
            authentication: {
                guard let applicationKey = Actito.shared.servicesInfo?.applicationKey,
                      let applicationSecret = Actito.shared.servicesInfo?.applicationSecret else {
                    logger.warning("Actito application authentication not configured.")
                    return nil
                }

                return .basic(username: applicationKey, password: applicationSecret)
            }()
        )
    }
}
