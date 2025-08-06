//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit
import ActitoKit

internal class ActitoLegacyCallbackViewController: UIViewController, ActitoCallbackViewController {
    private var theme: ActitoOptions.Theme?

    private var onClose: () -> Void
    private var onSend: () async -> Void

    private var activityIndicatorView: UIActivityIndicatorView!
    private var closeButton: UIBarButtonItem!
    private var sendButton: UIBarButtonItem!

    @MainActor internal var message: String? {
        return messageField.text ?? messageView.text
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

        view.setItems(
            [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                sendButton,
            ],
            animated: false
        )

        return view
    }()

    // MARK: - UI constraints

    private lazy var messageViewConstraints: [NSLayoutConstraint] = [
        messageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        messageView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
        messageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        messageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
    ]

    private lazy var imageViewConstraints: [NSLayoutConstraint] = [
        // Image view: square
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
        imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        imageView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        imageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
    ]

    private lazy var imageViewConstraintsWithKeyboard: [NSLayoutConstraint] = [
        imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        imageView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
        imageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
    ]

    private lazy var messageFieldConstraints: [NSLayoutConstraint] = [
        messageField.topAnchor.constraint(equalTo: toolbar.topAnchor),
        messageField.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
        messageField.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 16),
        messageField.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -16 - 44),
    ]

    private lazy var toolbarConstraints: [NSLayoutConstraint] = [
        toolbar.topAnchor.constraint(equalTo: messageView.bottomAnchor),
        toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
    ]

    private lazy var toolbarConstraintsWithKeyboard: [NSLayoutConstraint] = [
        toolbar.topAnchor.constraint(equalTo: imageView.bottomAnchor),
        toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
    ]

    private lazy var toolbarBottomConstraint: NSLayoutConstraint = toolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)

    // MARK: - Constructors

    public init(notification: ActitoNotification, onClose: @escaping () -> Void, onSend: @escaping () async -> Void) {
        self.onClose = onClose
        self.onSend = onSend

        super.init(nibName: nil, bundle: nil)

        theme  = Actito.shared.options!.theme(for: self)

        self.title = notification.title ?? Bundle.main.applicationName
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override internal func viewDidLoad() {
        super.viewDidLoad()

        if let colorStr = theme?.backgroundColor {
            self.view.backgroundColor = UIColor(hexString: colorStr)
        } else {
            self.view.backgroundColor = .systemBackground
        }

        setupNavigationActions()

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
    }

    // MARK: - Internal API

    internal func showKeyboardView() {
        self.view.addSubview(messageView)
        self.view.addSubview(toolbar)

        NSLayoutConstraint.activate(messageViewConstraints)
        NSLayoutConstraint.activate(toolbarConstraints)
        NSLayoutConstraint.activate([toolbarBottomConstraint])

        messageView.becomeFirstResponder()
    }

    internal func showMediaView(image: UIImage?) {
        imageView.image = image
        self.view.addSubview(imageView)

        NSLayoutConstraint.activate(imageViewConstraints)

        self.navigationItem.rightBarButtonItem = sendButton
    }

    internal func showMediaWithKeyboardView(image: UIImage?) {
        imageView.image = image
        self.view.addSubview(imageView)
        toolbar.addSubview(messageField)
        self.view.addSubview(toolbar)

        NSLayoutConstraint.activate(imageViewConstraintsWithKeyboard)
        NSLayoutConstraint.activate(messageFieldConstraints)
        NSLayoutConstraint.activate(toolbarConstraintsWithKeyboard)
        NSLayoutConstraint.activate([toolbarBottomConstraint])

        messageField.becomeFirstResponder()
    }

    // MARK: - Private API

    private func setupNavigationActions() {
        if Actito.shared.options?.legacyNotificationsUserInterfaceEnabled == true {
            setupLegacyNavigationActions()
        } else {
            setupModernNavigationActions()
        }

        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.hidesWhenStopped = true
        if let colorStr = theme?.activityIndicatorColor {
            activityIndicatorView.tintColor = UIColor(hexString: colorStr)
        }

        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
    }

    private func setupLegacyNavigationActions() {
        if let image = ActitoLocalizable.image(resource: .close) {
            closeButton = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(onCloseButtonClicked)
            )

            if let colorStr = theme?.actionButtonTextColor {
                closeButton.tintColor = UIColor(hexString: colorStr)
            }
        } else {
            closeButton = UIBarButtonItem(
                title: ActitoLocalizable.string(resource: .closeButton),
                style: .plain,
                target: self,
                action: #selector(onCloseButtonClicked)
            )

            if let colorStr = theme?.actionButtonTextColor {
                closeButton.tintColor = UIColor(hexString: colorStr)
            }
        }

        if let image = ActitoLocalizable.image(resource: .send) {
            sendButton = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(onSendButtonClicked)
            )

            if let colorStr = theme?.buttonTextColor {
                sendButton.tintColor = UIColor(hexString: colorStr)
            }
        } else {
            sendButton = UIBarButtonItem(
                title: ActitoLocalizable.string(resource: .sendButton),
                style: .plain,
                target: self,
                action: #selector(onSendButtonClicked)
            )

            if let colorStr = theme?.buttonTextColor {
                sendButton.tintColor = UIColor(hexString: colorStr)
            }        }
    }

    private func setupModernNavigationActions() {
        closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(onCloseButtonClicked)
        )

        sendButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.right"),
            style: .plain,
            target: self,
            action: #selector(onSendButtonClicked)
        )

        if let colorStr = theme?.buttonTextColor {
            sendButton.tintColor = UIColor(hexString: colorStr)
        }
    }

    @objc private func onCloseButtonClicked() {
        onClose()
    }

    @objc private func onSendButtonClicked() {
        sendButton.isEnabled = false
        activityIndicatorView.startAnimating()

        Task {
            await onSend()
        }
    }

    @objc private func keyboardWillAppear(_ notification: Notification) {
        guard UIDevice.current.userInterfaceIdiom != .pad else {
            return
        }

        guard let userInfo = notification.userInfo,
              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        toolbarBottomConstraint.constant = -(keyboardRect.height - self.view.safeAreaInsets.bottom)
    }

    @objc private func keyboardWillDisappear(_ notification: Notification) {
        toolbarBottomConstraint.constant = 0
    }
}
