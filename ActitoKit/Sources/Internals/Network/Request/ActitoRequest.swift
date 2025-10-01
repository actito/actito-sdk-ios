//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import UIKit

public struct ActitoRequest: Sendable {
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil

        return URLSession(configuration: configuration)
    }()

    private let request: URLRequest
    private let validStatusCodes: ClosedRange<Int>

    public func response() async throws -> (response: HTTPURLResponse, data: Data?) {
        let (response, data) = try await ActitoRequest.session.perform(request)
        return try handleResponse(response, data)
    }

    public func responseDecodable<T: Decodable & Sendable>(_ type: T.Type) async throws -> T {
        let (response, data) = try await response()

        guard let data = data else {
            throw ActitoNetworkError.noResponseData(response)
        }

        return try JSONDecoder.actito.decode(type, from: data)
    }

    private func handleResponse(_ response: HTTPURLResponse, _ data: Data?) throws -> (response: HTTPURLResponse, data: Data?) {
        guard validStatusCodes.contains(response.statusCode) else {
            throw ActitoNetworkError.validationError(response: response, data: data, validStatusCodes: validStatusCodes)
        }

        return (response, data)
    }

    @MainActor
    public class Builder {
        private var baseUrl: String?
        private var url: String?
        private var queryItems = [String: String]()
        private var authentication: Authentication?
        private var headers = [String: String]()
        private var method: String?
        private var body: Data?
        private var bodyEncodingError: Error?
        private var validStatusCodes: ClosedRange<Int> = 200 ... 299

        public init() {
            authentication = createDefaultAuthentication()
        }

        public func baseUrl(url: String) -> Self {
            baseUrl = url
            return self
        }

        public func get(_ url: String) -> Self {
            self.url = url
            method = "GET"
            return self
        }

        public func patch(_ url: String) -> Self {
            self.url = url
            method = "PATCH"
            return self
        }

        public func patch<T: Encodable>(_ url: String, body: T?) -> Self {
            _ = patch(url)
            encode(body)
            return self
        }

        public func post(_ url: String) -> Self {
            self.url = url
            method = "POST"
            return self
        }

        public func post<T: Encodable>(_ url: String, body: T?) -> Self {
            _ = post(url)
            encode(body)
            return self
        }

        public func post(_ url: String, body: [URLQueryItem]) -> Self {
            _ = post(url)
            encode(body)
            return self
        }

        public func post(_ url: String, body: Data, contentType: String) -> Self {
            _ = post(url)
            self.body = body
            headers["Content-Type"] = contentType
            return self
        }

        public func put(_ url: String) -> Self {
            self.url = url
            method = "PUT"
            return self
        }

        public func put<T: Encodable>(_ url: String, body: T?) -> Self {
            _ = put(url)
            encode(body)
            return self
        }

        public func delete(_ url: String) -> Self {
            self.url = url
            method = "DELETE"
            return self
        }

        public func delete<T: Encodable>(_ url: String, body: T?) -> Self {
            _ = delete(url)
            encode(body)
            return self
        }

        public func query(items: [String: String?]) -> Self {
            items.forEach { name, value in
                queryItems[name] = value
            }

            return self
        }

        public func query(name: String, value: String?) -> Self {
            queryItems[name] = value
            return self
        }

        public func header(name: String, value: String?) -> Self {
            headers[name] = value
            return self
        }

        public func authentication(_ authentication: Authentication?) -> Self {
            self.authentication = authentication
            return self
        }

        public func validate(range: ClosedRange<Int>) -> Self {
            validStatusCodes = range
            return self
        }

        public func build() throws -> ActitoRequest {
            if let error = bodyEncodingError {
                throw error
            }

            let url = try computeCompleteUrl()

            guard let method = method else {
                throw ActitoError.invalidArgument(message: "Provide the HTTP method for the request.")
            }

            var request = URLRequest(url: url)
            request.httpMethod = method
            request.httpBody = body

            // Append all available consumer headers.
            headers.forEach { header, value in
                request.setValue(value, forHTTPHeaderField: header)
            }

            let language = Actito.shared.device().preferredLanguage
            ?? "\(Locale.current.deviceLanguage())-\(Locale.current.deviceRegion())"

            // Ensure the standard Actito headers are added.
            request.setValue(language, forHTTPHeaderField: "Accept-Language")
            request.setValue(UIDevice.current.userAgent(sdkVersion: Actito.SDK_VERSION), forHTTPHeaderField: "User-Agent")
            request.setValue(Actito.SDK_VERSION, forHTTPHeaderField: "X-Notificare-SDK-Version")
            request.setValue(Bundle.main.applicationVersion, forHTTPHeaderField: "X-Notificare-App-Version")

            // Add application authentication when available
            if let authentication = authentication {
                request.setValue(authentication.encode(), forHTTPHeaderField: "Authorization")
            }

            return ActitoRequest(
                request: request,
                validStatusCodes: validStatusCodes
            )
        }

        public func response(_ completion: @Sendable @escaping (Result<(response: HTTPURLResponse, data: Data?), Error>) -> Void) {
            Task {
                do {
                    let result = try await response()
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        @discardableResult
        public func response() async throws -> (response: HTTPURLResponse, data: Data?) {
            return try await build().response()
        }

        public func responseDecodable<T: Decodable & Sendable>(_ type: T.Type, _ completion: @Sendable @escaping (Result<T, Error>) -> Void) {
            Task {
                do {
                    let model = try await responseDecodable(type)
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        public func responseDecodable<T: Decodable & Sendable>(_ type: T.Type) async throws -> T {
            return try await build().responseDecodable(type)
        }

        // MARK: - Private API

        private func computeCompleteUrl() throws -> URL {
            guard var urlStr = url else {
                throw ActitoError.invalidArgument(message: "Provide a URL for the request.")
            }

            if !urlStr.starts(with: "http://"), !urlStr.starts(with: "https://") {
                guard var baseUrl = baseUrl ?? Actito.shared.servicesInfo?.hosts.restApi else {
                    throw ActitoError.invalidArgument(message: "Unable to determine the base url for the request.")
                }

                urlStr = !baseUrl.hasSuffix("/") && !urlStr.hasPrefix("/")
                    ? "\(baseUrl)/\(urlStr)"
                    : "\(baseUrl)\(urlStr)"
            }

            guard var url = URL(string: urlStr) else {
                throw ActitoError.invalidArgument(message: "Invalid url '\(urlStr)'.")
            }

            if !queryItems.isEmpty {
                queryItems.forEach { key, value in
                    url.appendQueryComponent(name: key, value: value)
                }
            }

            return url
        }

        private func createDefaultAuthentication() -> Authentication? {
            guard let applicationKey = Actito.shared.servicesInfo?.applicationKey,
                  let applicationSecret = Actito.shared.servicesInfo?.applicationSecret
            else {
                logger.warning("Actito application authentication not configured.")
                return nil
            }

            return .basic(username: applicationKey, password: applicationSecret)
        }

        private func encode<T: Encodable>(_ body: T?) {
            if let body = body {
                do {
                    self.body = try JSONEncoder.actito.encode(body)
                    headers["Content-Type"] = "application/json"
                } catch {
                    bodyEncodingError = error
                }
            }
        }

        private func encode(_ body: [URLQueryItem]) {
            let parameters = body.map { item -> String in
                let key = item.name
                let value = item.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                return "\(key)=\(value ?? "")"
            }

            self.body = parameters.joined(separator: "&").data(using: .utf8)
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        }
    }

    public enum Authentication {
        case basic(username: String, password: String)

        public func encode() -> String {
            switch self {
            case let .basic(username, password):
                let base64encoded = "\(username):\(password)"
                    .data(using: .utf8)!
                    .base64EncodedString()

                return "Basic \(base64encoded)"
            }
        }
    }
}
