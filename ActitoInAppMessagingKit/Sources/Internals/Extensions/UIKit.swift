//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

extension UIView {
    internal var ncSafeAreaLayoutGuide: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        }

        return layoutMarginsGuide
    }
}
