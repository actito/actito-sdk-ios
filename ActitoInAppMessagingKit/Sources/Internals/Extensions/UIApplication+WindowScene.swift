//
// Copyright (c) 2026 Actito. All rights reserved.
//

import UIKit

extension UIApplication {
    internal var focusedWindowScene: UIWindowScene? {
        let scenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        let active = scenes.filter { $0.activationState == .foregroundActive }

        // An active scene hosting the app's key window is the one receiving input.
        return active.first { $0.keyWindow != nil }
            // Otherwise, any active scene (e.g. mid-transition, no key window yet).
            ?? active.first
            // Last resort: whichever scene last held the key window.
        ?? scenes.first { $0.keyWindow != nil }
    }
}
