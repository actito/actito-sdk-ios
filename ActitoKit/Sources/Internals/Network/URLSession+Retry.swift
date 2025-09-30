//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension URLSession {
    /// Default number of retries to attempt on each `URLRequest` instance. To customize, supply desired value to `perform()`
    public static let maximumNumberOfRetries: Int = 5
    public static let initialDelayNanoseconds: UInt64 = 500_000_000 // 0.5s in nanoseconds
    public static let backoffFactor: UInt64 = 2

    /// Output types
    public typealias DataResult = (response: HTTPURLResponse, data: Data?)

    /// Executes a given `URLRequest` instance, possibly retrying the request up to `maxRetries`.
    /// Returns either the response data or throws an `ActitoNetworkError`.
    /// If any authentication needs to be done, it's handled internally by this methods and its derivatives.
    /// - Parameters:
    ///   - urlRequest: URLRequest instance to execute.
    ///   - maxRetries: Number of automatic retries (default is 5).
    ///   - allowEmptyData: Allow the return of  empty `Data` or return nil instead.
    public func perform(
        _ urlRequest: URLRequest,
        maxRetries: Int = URLSession.maximumNumberOfRetries,
        allowEmptyData: Bool = false,
    ) async throws -> DataResult {
        if maxRetries <= 0 {
            fatalError("maxRetries must be 1 or larger.")
        }

        let networkRequest = NetworkRequest(urlRequest, maxRetries, allowEmptyData)

        do {
            return try await authenticate(networkRequest)
        } catch let error as ActitoNetworkError where error.shouldRetry {
            return try await retryPerform(networkRequest)
        } catch {
            throw error
        }
    }

    private func retryPerform(_ networkRequest: NetworkRequest) async throws -> DataResult {
        var attempt = 0
        let maxRetries = networkRequest.maxRetries
        let backoffFactor = URLSession.backoffFactor
        var delay = URLSession.initialDelayNanoseconds

        while attempt < maxRetries {
            do {
                return try await authenticate(networkRequest)
            } catch let error as ActitoNetworkError where error.shouldRetry {
                attempt += 1

                guard attempt < maxRetries else { break }

                try await Task.sleep(nanoseconds: delay)
                delay *= backoffFactor
            } catch {
                throw error
            }
        }

        throw ActitoNetworkError.inaccessible
    }
}

extension URLSession {
    /// Helper type which groups `URLRequest` (input) along with helpful processing properties, like number of retries.
    private typealias NetworkRequest = (
        // swiftlint:disable:previous large_tuple
        urlRequest: URLRequest,
        maxRetries: Int,
        allowEmptyData: Bool,
    )

    /// Extra-step where `URLRequest`'s authorization should be handled, before actually performing the URLRequest in `execute()`
    private func authenticate(_ networkRequest: NetworkRequest) async throws -> DataResult {
        //    NOTE: this is the place to handle OAuth2
        //    or some other form of URLRequest‘s authorization
        //    now execute the request
        return try await execute(networkRequest)
    }

    /// Creates the instance of `URLSessionDataTask` and executes it, validating the result.
    private func execute(_ networkRequest: NetworkRequest) async throws -> DataResult {
        do {
            let (data, response) = try await data(for: networkRequest.urlRequest)

            guard let httpURLResponse = response as? HTTPURLResponse else {
                throw ActitoNetworkError.invalidResponseType(response)
            }

            if data.isEmpty && !networkRequest.allowEmptyData {
                return (httpURLResponse, nil)
            }

            return (httpURLResponse, data)
        } catch {
            if let urlError = error as? URLError {
                throw ActitoNetworkError.urlError(urlError)
            } else {
                throw ActitoNetworkError.genericError(error)
            }
        }
    }
}
