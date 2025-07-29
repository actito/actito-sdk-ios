//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

@available(iOS 19.0, *)
internal class ActitoLiquidGlassCallbackView: ActitoBaseCallbackView {
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

    private lazy var messageFieldEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.contentView.addSubview(messageField)
        view.translatesAutoresizingMaskIntoConstraints = false
        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = true

        UIView.animate {
            view.effect = glassEffect
        }

        return view
    }()

    private lazy var stackView: UIStackView = {
        sendButton.configuration = .prominentGlass()

        NSLayoutConstraint.activate([
            sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor),
        ])

        let view: UIStackView

        if action.camera {
            view = UIStackView(arrangedSubviews: [messageFieldEffectView, sendButton])
        } else {
            view = UIStackView(arrangedSubviews: [UIView(), sendButton])
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 8

        return view
    }()

    // MARK: - UI constraints

    private lazy var messageViewConstraints: [NSLayoutConstraint] = [
        messageView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
        messageView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
        messageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
        messageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
    ]

    private lazy var imageViewConstraints: [NSLayoutConstraint] = [
        // Image view: square
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
        imageView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
        imageView.bottomAnchor.constraint(lessThanOrEqualTo: viewController.view.safeAreaLayoutGuide.bottomAnchor),
        imageView.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor),
    ]

    private lazy var messageFieldConstraints: [NSLayoutConstraint] = [
        messageField.topAnchor.constraint(equalTo: messageFieldEffectView.topAnchor),
        messageField.bottomAnchor.constraint(equalTo: messageFieldEffectView.bottomAnchor),
        messageField.leadingAnchor.constraint(equalTo: messageFieldEffectView.leadingAnchor, constant: 16),
        messageField.trailingAnchor.constraint(equalTo: messageFieldEffectView.trailingAnchor, constant: -8),
    ]

    private lazy var stackViewConstraints: [NSLayoutConstraint] = [
        stackView.heightAnchor.constraint(equalToConstant: 44),
        stackView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 16),
        stackView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16),
    ]

    private lazy var stackViewBottomConstraint: NSLayoutConstraint = stackView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)

    // MARK: - Private API

    override internal func setupKeyboard() {
        viewController.view.addSubview(messageView)
        viewController.view.addSubview(stackView)

        NSLayoutConstraint.activate(messageViewConstraints)
        NSLayoutConstraint.activate(stackViewConstraints)
        NSLayoutConstraint.activate([stackViewBottomConstraint])

        messageView.becomeFirstResponder()
    }

    override internal func setupMedia(image: UIImage?) {
        imageView.image = image
        viewController.view.addSubview(imageView)

        NSLayoutConstraint.activate(imageViewConstraints)

        let sendBarButton = UIBarButtonItem(customView: self.sendButton)

        self.sendButton.tintColor = .white
        sendBarButton.style = .prominent

        viewController.navigationItem.rightBarButtonItem = sendBarButton
    }

    override internal func setupMediaWithKeyboard(image: UIImage?) {
        imageView.image = image
        viewController.view.addSubview(imageView)
        viewController.view.addSubview(stackView)

        NSLayoutConstraint.activate(imageViewConstraints)
        NSLayoutConstraint.activate(messageFieldConstraints)
        NSLayoutConstraint.activate(stackViewConstraints)
        NSLayoutConstraint.activate([stackViewBottomConstraint])

        messageField.becomeFirstResponder()
    }

    override internal func adjustBottomConstraint(for keyboardHeight: CGFloat) {
        stackViewBottomConstraint.constant = -(keyboardHeight - viewController.view.safeAreaInsets.bottom + 8)
    }

    override internal func resetBottomConstraint() {
        stackViewBottomConstraint.constant = 0
    }
}
