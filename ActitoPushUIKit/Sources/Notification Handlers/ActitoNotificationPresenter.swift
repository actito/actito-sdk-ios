//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

@MainActor
internal protocol ActitoNotificationPresenter {
    func present(in controller: UIViewController)
}
