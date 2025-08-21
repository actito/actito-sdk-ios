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

        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
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
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            return
        }

        let html = content.data as! String
        webView.loadHTMLString(html, baseURL: URL(string: ""))

        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didPresentNotification: self.notification)

        // Check if we should show any possible actions
        if html.contains("notificareOpenAction") || html.contains("notificareOpenActions") {
            isActionsButtonEnabled = false
        }
    }
}

extension ActitoWebViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @MainActor @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if let scheme = url.scheme, Actito.shared.options!.urlSchemes.contains(scheme) {
            handleActitoQueryParameters(for: url)
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didClickURL: url, in: self.notification)

            decisionHandler(.cancel)
        } else if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            decisionHandler(.allow)
        } else {
            handleActitoQueryParameters(for: url)

            // Let's handle custom URLs if not http or https.
            if
                let url = navigationAction.request.url,
                let urlScheme = url.scheme,
                urlScheme != "http", urlScheme != "https",
                Bundle.main.getSupportedUrlSchemes().contains(urlScheme) || UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url, options: [:]) { _ in
                    decisionHandler(.cancel)
                }

                return
            }

            if hasActitoQueryParameters(in: url) {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    public func webView(_: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @MainActor @escaping () -> Void) {
        let alert = UIAlertController(title: Bundle.main.applicationName,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(title: ActitoLocalizable.string(resource: .okButton), style: .default, handler: { _ in
                completionHandler()
            })
        )

        present(alert, animated: true, completion: nil)
    }

    public func webView(_: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @MainActor @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: Bundle.main.applicationName,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(title: ActitoLocalizable.string(resource: .okButton), style: .default, handler: { _ in
                completionHandler(true)
            })
        )

        alert.addAction(
            UIAlertAction(title: ActitoLocalizable.string(resource: .cancelButton), style: .cancel, handler: { _ in
                completionHandler(false)
            })
        )

        present(alert, animated: true, completion: nil)
    }

    public func webView(_: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame _: WKFrameInfo, completionHandler: @MainActor @escaping (String?) -> Void) {
        let alert = UIAlertController(title: Bundle.main.applicationName,
                                      message: prompt,
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = defaultText
        }

        alert.addAction(
            UIAlertAction(title: ActitoLocalizable.string(resource: .okButton), style: .default, handler: { _ in
                if let text = alert.textFields?.first?.text, !text.isEmpty {
                    completionHandler(text)
                } else {
                    completionHandler(defaultText)
                }
            })
        )

        alert.addAction(
            UIAlertAction(title: ActitoLocalizable.string(resource: .cancelButton), style: .cancel, handler: { _ in
                completionHandler(nil)
            })
        )

        present(alert, animated: true, completion: nil)
    }
}

extension ActitoWebViewController: ActitoNotificationPresenter {
    internal func present(in controller: UIViewController) {
        controller.presentOrPush(self)
    }
}
