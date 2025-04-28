//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import UIKit

public protocol ActitoLoyaltyIntegration {
    var canPresentPasses: Bool { get }

    func present(notification: ActitoNotification, in viewController: UIViewController)
}
