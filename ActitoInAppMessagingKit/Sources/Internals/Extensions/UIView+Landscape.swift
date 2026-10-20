//
// Copyright (c) 2026 Actito. All rights reserved.
//

import UIKit

extension UIView {
    /// Whether the view should be treated as landscape.
    ///
    /// Landscape should be determined using size classes.
    /// For iPad and foldable inner displays, where size classes are regular/regular,
    /// the shape of the view is used to decide.
    ///
    /// A layout is landscape when:
    /// - compact/compact: smaller iPhones in landscape
    /// - regular/compact: larger iPhones (i.e. Pro, Max, Pro Max) in landscape
    /// - regular/regular: iPads and large foldable displays, depending on the view shape
    internal var isLandscape: Bool {
        let traits = traitCollection

        if traits.horizontalSizeClass == .regular && traits.verticalSizeClass == .regular {
            return bounds.width > bounds.height
        }

        return !(traits.horizontalSizeClass == .compact && traits.verticalSizeClass == .regular)
    }
}
