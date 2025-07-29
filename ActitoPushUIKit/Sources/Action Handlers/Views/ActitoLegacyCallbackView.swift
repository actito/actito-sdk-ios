//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

internal class ActitoLegacyCallbackView: ActitoBaseCallbackView {
    override internal var message: String? {
        if action.camera, action.keyboard {
            return messageField.text
        }

        if action.keyboard {
            return messageView.text
        }

        return nil
    }

    // MARK: - UI Views

    private lazy var messageView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 16)
        view.autocorrectionType = .default
        view.keyboardType = .default
        view.returnKeyType = .default
        view.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        if let colorStr = theme?.textFieldBackgroundColor {
            view.backgroundColor = UIColor(hexString: colorStr)
        }
        if let colorStr = theme?.textFieldTextColor {
            view.textColor = UIColor(hexString: colorStr)
        }

        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true

        return view
    }()

    private lazy var messageField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = ActitoLocalizable.string(resource: .actionsInputPlaceholder)
        view.borderStyle = .none
        if let colorStr = theme?.textFieldBackgroundColor {
            view.backgroundColor = UIColor(hexString: colorStr)
        }
        if let colorStr = theme?.textFieldTextColor {
            view.textColor = UIColor(hexString: colorStr)
        }
        view.font = UIFont.systemFont(ofSize: 14)
        view.autocorrectionType = .default
        view.keyboardType = .default
        view.returnKeyType = .default
        view.clearButtonMode = .whileEditing
        view.contentVerticalAlignment = .center

        return view
    }()

    private lazy var toolbar: UIToolbar = {
        let view = UIToolbar(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
        view.setContentHuggingPriority(UILayoutPriority(rawValue: 751), for: .vertical)
        if let colorStr = theme?.toolbarBackgroundColor {
            view.barTintColor = UIColor(hexString: colorStr)
        }

        let sendButton = UIBarButtonItem(customView: self.sendButton)

        view.setItems(
            [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                sendButton,
            ],
            animated: false
        )

        if action.keyboard, action.camera {
            view.addSubview(messageField)
        }

        return view
    }()

    // MARK: - UI constraints

    private lazy var messageViewConstraints: [NSLayoutConstraint] = [
        messageView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
        messageView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
        messageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
        messageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
    ]

    private lazy var imageViewConstraints: [NSLayoutConstraint] = {
        if action.keyboard {
            let constraints = [
            imageView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor),
            ]

            return constraints
        }

        let constraints = [
            // Image view: square
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: viewController.view.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor),
        ]

        return constraints
    }()

    private lazy var messageFieldConstraints: [NSLayoutConstraint] = [
        messageField.topAnchor.constraint(equalTo: toolbar.topAnchor),
        messageField.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
        messageField.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 16),
        messageField.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -16 - 44),
    ]

    private lazy var toolbarConstraints: [NSLayoutConstraint] = {
        if action.camera {
            let constraints = [
                toolbar.topAnchor.constraint(equalTo: imageView.bottomAnchor),
                toolbar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                toolbar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            ]

            return constraints
        }

        let constraints = [
            toolbar.topAnchor.constraint(equalTo: messageView.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
        ]

        return constraints
    }()

    private lazy var toolbarBottomConstraint: NSLayoutConstraint = toolbar.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)

    // MARK: - Private API

    override internal func setupKeyboard() {
        viewController.view.addSubview(messageView)
        viewController.view.addSubview(toolbar)

        NSLayoutConstraint.activate(messageViewConstraints)
        NSLayoutConstraint.activate(toolbarConstraints)
        NSLayoutConstraint.activate([toolbarBottomConstraint])

        messageView.becomeFirstResponder()
    }

    override internal func setupMedia(image: UIImage?) {
        imageView.image = image
        viewController.view.addSubview(imageView)

        NSLayoutConstraint.activate(imageViewConstraints)

        let sendBarButton = UIBarButtonItem(customView: self.sendButton)

        viewController.navigationItem.rightBarButtonItem = sendBarButton
    }

    override internal func setupMediaWithKeyboard(image: UIImage?) {
        imageView.image = image
        viewController.view.addSubview(imageView)
        viewController.view.addSubview(toolbar)

        NSLayoutConstraint.activate(imageViewConstraints)
        NSLayoutConstraint.activate(messageFieldConstraints)
        NSLayoutConstraint.activate(toolbarConstraints)
        NSLayoutConstraint.activate([toolbarBottomConstraint])

        messageField.becomeFirstResponder()
    }

    override internal func adjustBottomConstraint(for keyboardHeight: CGFloat) {
        toolbarBottomConstraint.constant = -(keyboardHeight - viewController.view.safeAreaInsets.bottom)
    }

    override internal func resetBottomConstraint() {
        toolbarBottomConstraint.constant = 0
    }
}
