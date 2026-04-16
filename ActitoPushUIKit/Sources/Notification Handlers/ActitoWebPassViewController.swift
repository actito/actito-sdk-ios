//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit
import WebKit

public class ActitoWebPassViewController: ActitoBaseNotificationViewController {
    private var webView: WKWebView!
    private var loadingView: UIView!
    private var progressView: UIProgressView!
    private var brightness: CGFloat = 0
    private var webViewProgressObserver: NSKeyValueObservation?

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupContent()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        webViewProgressObserver = webView.observe(\.estimatedProgress, options: .new) { webView, _ in
            DispatchQueue.main.async {
                self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            }
        }

        brightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        webViewProgressObserver = nil
        UIScreen.main.brightness = brightness

        DispatchQueue.main.async {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
        }
    }

    private func setupViews() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // View setup.
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)

        // Clear cache.
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0),
                                                completionHandler: {})

        // WebView constraints
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

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
              let host = Actito.shared.servicesInfo?.hosts.restApi
        else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        let id: String?

        switch notification.type {
        case ActitoNotification.NotificationType.passbook.rawValue:
            id = extractPassBookId(from: content)

        case ActitoNotification.NotificationType.pass.rawValue:
            id = extractPassId(from: content)

        default:
            id = nil
        }

        guard let id,
              let url = URL(string: "\(host)/pass/web/\(id)?showWebVersion=1")
        else {
            DispatchQueue.main.async {
                Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        webView.load(URLRequest(url: url))
    }

    private func extractPassBookId(from content: ActitoNotification.Content) -> String? {
        guard content.type == "re.notifica.content.PKPass",
              let passUrlStr = content.data as? String
        else {
            return nil
        }

        return passUrlStr.components(separatedBy: "/").last
    }

    private func extractPassId(from content: ActitoNotification.Content) -> String? {
        guard content.type == "re.notifica.content.Pass",
              let data = content.data as? [String: String]
        else {
            return nil
        }

        let serial = data["serial"]
        let barcode = data["barcode"]

        if let serial, !serial.isEmpty {
            return serial
        }

        if let barcode, !barcode.isEmpty {
            return barcode
        }

        return nil
    }
}

extension ActitoWebPassViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return .cancel
        } else {
            return .allow
        }
    }

    public func webView(_: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        if navigationResponse.response.mimeType == "application/vnd.apple.pkpass", let url = navigationResponse.response.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return .cancel
        } else {
            return .allow
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
}

extension ActitoWebPassViewController: ActitoNotificationPresenter {
    internal func present(in controller: UIViewController) {
        controller.presentOrPush(self)
    }
}
