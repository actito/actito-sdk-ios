//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoKit

internal struct ActitoTestRestApiClient {
    internal func get(url: String) async throws -> (response: HTTPURLResponse, data: Data?) {
        let auth = getAuthentication()

        return try await ActitoRequest.Builder()
            .authentication(
                ActitoRequest.Authentication.basic(
                    username: auth.key,
                    password: auth.secret,
                ),
            )
            .get(url)
            .response()
    }

    private func getAuthentication() -> (key: String, secret: String) {
        guard let path = Bundle(identifier: "com.actito.ActitoTestSupportKit")?.path(forResource: "TestActitoServices", ofType: "plist") else {
            fatalError("TestActitoServices.plist is missing.")
        }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil),
              let dict = plist as? [String: Any],
              let key = dict["APPLICATION_KEY"] as? String,
              let masterSecret = dict["APPLICATION_MASTER_SECRET"] as? String
        else {
            fatalError("Invalid TestActitoServices.plist format.")
        }

        return (key, masterSecret)
    }
}
