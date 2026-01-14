//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import UIKit
import WebKit

public class ActitoUrlViewController: ActitoBaseNotificationViewController {
    private var webView: WKWebView!
    private var loadingView: UIView!
    private var progressView: UIProgressView!
    private var webViewProgressObserver: NSKeyValueObservation?

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupContent()

        // Start as false regardless of available actions.
        // The final decision will be made after loading the HTML content.
        isActionsButtonEnabled = false
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        webViewProgressObserver = webView.observe(\.estimatedProgress, options: .new) { webView, _ in
            DispatchQueue.main.async {
                self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            }
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        webViewProgressObserver = nil

        // NOTE: Loading a blank view to prevent the videos from continuing
        // playing after dismissing the view controller.
        webView.load(URLRequest(url: URL(string: "about:blank")!))

        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
        }
    }

    private func setupViews() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let metaTag = "webkit.messageHandlers.notificareWebViewLoading.postMessage(document.body.innerHTML);"
        let metaScript = WKUserScript(source: metaTag, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(metaScript)
        configuration.userContentController.add(self, name: "notificareWebViewLoading")

        // View setup.
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)

        // WebView constraints
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Clear cache.
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0),
                                                completionHandler: {})

        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        if let colorStr = theme?.backgroundColor {
            loadingView.backgroundColor = UIColor(hexString: colorStr)
        } else {
            loadingView.backgroundColor = .systemBackground
        }

        view.addSubview(loadingView)

        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        // Progress view constraints
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 150),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupContent() {
        guard let content = notification.content.first,
              let url = URL(string: content.data as! String)?.removingQueryComponent(name: "notificareWebView")
        else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        webView.load(URLRequest(url: url))
    }
}

extension ActitoUrlViewController: WKScriptMessageHandler {
    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "notificareWebViewLoading" {
            guard let html = message.body as? String else {
                isActionsButtonEnabled = !notification.actions.isEmpty
                return
            }

            isActionsButtonEnabled = !html.contains("notificareOpenAction") && !html.contains("notificareOpenActions") && !notification.actions.isEmpty
        }
    }
}

extension ActitoUrlViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else {
            return .cancel
        }

        if let scheme = url.scheme, Actito.shared.options!.urlSchemes.contains(scheme) {
            handleActitoQueryParameters(for: url)

            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didClickURL: url, in: self.notification)
            }

            return .cancel
        } else if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            return .allow
        } else {
            handleActitoQueryParameters(for: url)

            // Let's handle custom URLs if not http or https.
            if
                let url = navigationAction.request.url,
                let urlScheme = url.scheme,
                urlScheme != "http", urlScheme != "https",
                Bundle.main.getSupportedUrlSchemes().contains(urlScheme) || UIApplication.shared.canOpenURL(url)
            {
                await UIApplication.shared.open(url, options: [:])

                return .cancel
            }

            if hasActitoQueryParameters(in: url) {
                return .cancel
            } else {
                return .allow
            }
        }
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
        }

        loadingView.removeFromSuperview()
        progressView.removeFromSuperview()
    }

    public func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
        }

        loadingView.removeFromSuperview()
        progressView.removeFromSuperview()
    }

    public func webView(_: WKWebView, didFinish _: WKNavigation!) {
        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didPresentNotification: self.notification)
        }

        loadingView.removeFromSuperview()
        progressView.removeFromSuperview()
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async {
        let alert = UIAlertController(
            title: Bundle.main.applicationName,
            message: message,
            preferredStyle: .alert
        )

        await withCheckedContinuation { continuation in
            alert.addAction(
                UIAlertAction(title: ActitoLocalizable.string(resource: .okButton), style: .default) { _ in
                    continuation.resume()
                }
            )

            present(alert, animated: true, completion: nil)
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async -> Bool {
        let alert = UIAlertController(
            title: Bundle.main.applicationName,
            message: message,
            preferredStyle: .alert
        )

        return await withCheckedContinuation { continuation in
            alert.addAction(
                UIAlertAction(title: ActitoLocalizable.string(resource: .okButton), style: .default) { _ in
                    continuation.resume(returning: true)
                }
            )

            alert.addAction(
                UIAlertAction(title: ActitoLocalizable.string(resource: .cancelButton), style: .cancel) { _ in
                    continuation.resume(returning: false)
                }
            )

            present(alert, animated: true, completion: nil)
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo) async -> String? {
        let alert = UIAlertController(
            title: Bundle.main.applicationName,
            message: prompt,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.text = defaultText
        }

        return await withCheckedContinuation { continuation in
            alert.addAction(
                UIAlertAction(title: ActitoLocalizable.string(resource: .okButton), style: .default) { _ in
                    if let text = alert.textFields?.first?.text, !text.isEmpty {
                        continuation.resume(returning: text)
                    } else {
                        continuation.resume(returning: defaultText)
                    }
                }
            )

            alert.addAction(
                UIAlertAction(title: ActitoLocalizable.string(resource: .cancelButton), style: .cancel) { _ in
                    continuation.resume(returning: nil)
                }
            )

            present(alert, animated: true, completion: nil)
        }
    }
}

extension ActitoUrlViewController: ActitoNotificationPresenter {
    internal func present(in controller: UIViewController) {
        controller.presentOrPush(self)
    }
}
