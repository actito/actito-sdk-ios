//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit
import ActitoKit

@available(iOS 26.0, *)
internal class ActitoLiquidGlassCallbackViewController: UIViewController, ActitoCallbackViewController {
    private var theme: ActitoOptions.Theme?

    private var onClose: () -> Void
    private var onSend: () async -> Void

    private var activityIndicatorView: UIActivityIndicatorView!
    private var closeButton: UIBarButtonItem!
    private var sendButton: UIButton!

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

        view = UIStackView(arrangedSubviews: [sendButton])

        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 8

        return view
    }()

    // MARK: - UI constraints

    private lazy var messageViewConstraints: [NSLayoutConstraint] = [
        messageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        messageView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
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

    private lazy var messageFieldConstraints: [NSLayoutConstraint] = [
        messageField.topAnchor.constraint(equalTo: messageFieldEffectView.topAnchor),
        messageField.bottomAnchor.constraint(equalTo: messageFieldEffectView.bottomAnchor),
        messageField.leadingAnchor.constraint(equalTo: messageFieldEffectView.leadingAnchor, constant: 16),
        messageField.trailingAnchor.constraint(equalTo: messageFieldEffectView.trailingAnchor, constant: -8),
    ]

    private lazy var stackViewConstraints: [NSLayoutConstraint] = [
        stackView.heightAnchor.constraint(equalToConstant: 44),
        stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
        stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
    ]

    private lazy var stackViewBottomConstraint: NSLayoutConstraint = stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)

    // MARK: - Constructors

    public init(notification: ActitoNotification, onClose: @escaping () -> Void, onSend: @escaping () async -> Void) {
        self.onClose = onClose
        self.onSend = onSend

        super.init(nibName: nil, bundle: nil)

        theme = Actito.shared.options!.theme(for: self)

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

        stackView.insertArrangedSubview(UIView(), at: 0)
        self.view.addSubview(stackView)

        NSLayoutConstraint.activate(messageViewConstraints)
        NSLayoutConstraint.activate(stackViewConstraints)
        NSLayoutConstraint.activate([stackViewBottomConstraint])

        messageView.becomeFirstResponder()
    }

    internal func showMediaView(image: UIImage?) {
        imageView.image = image
        self.view.addSubview(imageView)

        NSLayoutConstraint.activate(imageViewConstraints)

        let sendBarButton = UIBarButtonItem(customView: self.sendButton)

        self.sendButton.tintColor = .white
        sendBarButton.style = .prominent

        self.navigationItem.rightBarButtonItem = sendBarButton
    }

    internal func showMediaWithKeyboardView(image: UIImage?) {
        imageView.image = image
        self.view.addSubview(imageView)

        stackView.insertArrangedSubview(messageFieldEffectView, at: 0)
        self.view.addSubview(stackView)

        NSLayoutConstraint.activate(imageViewConstraints)
        NSLayoutConstraint.activate(messageFieldConstraints)
        NSLayoutConstraint.activate(stackViewConstraints)
        NSLayoutConstraint.activate([stackViewBottomConstraint])

        messageField.becomeFirstResponder()
    }

    // MARK: - Private API

    private func setupNavigationActions() {
        setupModernNavigationActions()

        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.hidesWhenStopped = true
        if let colorStr = theme?.activityIndicatorColor {
            activityIndicatorView.tintColor = UIColor(hexString: colorStr)
        }

        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)

        self.navigationItem.rightBarButtonItem?.isHidden = true
    }

    private func setupModernNavigationActions() {
        closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(onCloseButtonClicked)
        )

        sendButton = UIButton()
        sendButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        sendButton.addTarget(self, action: #selector(onSendButtonClicked), for: .touchUpInside)

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

        stackViewBottomConstraint.constant = -(keyboardRect.height - self.view.safeAreaInsets.bottom + 8)
    }

    @objc private func keyboardWillDisappear(_ notification: Notification) {
        stackViewBottomConstraint.constant = 0
    }
}
