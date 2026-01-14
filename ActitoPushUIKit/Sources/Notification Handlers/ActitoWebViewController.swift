//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import UIKit
import WebKit

public class ActitoWebViewController: ActitoBaseNotificationViewController {
    private var webView: WKWebView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureWebView()
        setupContent()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // NOTE: Loading a blank view to prevent the videos from continuing
        // playing after dismissing the view controller.
        webView.load(URLRequest(url: URL(string: "about:blank")!))

        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
        }
    }

    private func configureWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = [.video, .audio]

        let metaTag = "var meta = document.createElement('meta');meta.name = 'viewport';meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';var head = document.getElementsByTagName('head')[0];head.appendChild(meta);"
        let metaScript = WKUserScript(source: metaTag, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(metaScript)

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
    }

    private func setupContent() {
        guard let content = notification.content.first else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        let html = content.data as! String

        if let bundleId = Bundle.main.bundleIdentifier, let referrerUrl = URL(string: "https://\(bundleId)".lowercased()) {
            webView.loadHTMLString(html, baseURL: referrerUrl)
        } else {
            webView.loadHTMLString(html, baseURL: nil)
        }

        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didPresentNotification: self.notification)
        }

        // Check if we should show any possible actions
        if html.contains("notificareOpenAction") || html.contains("notificareOpenActions") {
            isActionsButtonEnabled = false
        }
    }
}

extension ActitoWebViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
        }
    }

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

        return await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
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

        return await withCheckedContinuation { (continuation: CheckedContinuation<String?, Never>) in
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

extension ActitoWebViewController: ActitoNotificationPresenter {
    internal func present(in controller: UIViewController) {
        controller.presentOrPush(self)
    }
}
