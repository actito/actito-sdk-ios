//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

internal protocol ActitoCallbackViewController: UIViewController {
    var message: String? { get }

    func showKeyboardView()

    func showMediaView(image: UIImage?)

    func showMediaWithKeyboardView(image: UIImage?)
}
