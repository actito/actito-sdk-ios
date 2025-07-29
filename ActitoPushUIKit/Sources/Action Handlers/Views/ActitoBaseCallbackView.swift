//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

internal class ActitoBaseCallbackView: NSObject {
    internal let theme: ActitoOptions.Theme?
    internal let action: ActitoNotification.Action
    internal let viewController: UIViewController
    internal var sendButton: UIButton
    internal var message: String? {
        return nil
    }

    public init(theme: ActitoOptions.Theme?, action: ActitoNotification.Action, viewController: UIViewController, sendButton: UIButton, image: UIImage?) {
        self.theme = theme
        self.action = action
        self.viewController = viewController
        self.sendButton = sendButton

        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        if action.keyboard && action.camera {
            setupMediaWithKeyboard(image: image)
        } else if action.camera {
            setupMedia(image: image)
        } else if action.keyboard {
            setupKeyboard()
        }
    }

    internal func setupKeyboard() {}

    internal func setupMedia(image: UIImage?) {}

    internal func setupMediaWithKeyboard(image: UIImage?) {}

    @objc private func keyboardWillAppear(_ notification: Notification) {
        guard UIDevice.current.userInterfaceIdiom != .pad else {
            return
        }

        guard let userInfo = notification.userInfo,
              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        adjustBottomConstraint(for: keyboardRect.height)
    }

    @objc private func keyboardWillDisappear(_ notification: Notification) {
        resetBottomConstraint()
    }

    internal func adjustBottomConstraint(for keyboardHeight: CGFloat) {}

    internal func resetBottomConstraint() {}
}
