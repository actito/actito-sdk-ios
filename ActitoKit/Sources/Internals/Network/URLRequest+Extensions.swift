//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

extension URLRequest {
//    mutating func setBasicAuthentication(username: String, password: String) {
//        let base64encoded = "\(username):\(password)"
//            .data(using: .utf8)!
//            .base64EncodedString()
//
//        addValue("Basic \(base64encoded)", forHTTPHeaderField: "Authorization")
//    }

//    mutating func setBearerAuthentication(token: String) {
//        addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//    }

    public mutating func setActitoHeaders() {
        setValue(Actito.SDK_VERSION, forHTTPHeaderField: "X-Notificare-SDK-Version")
        setValue(Bundle.main.applicationVersion, forHTTPHeaderField: "X-Notificare-App-Version")
    }

    public mutating func setMethod(_ method: String, payload: Data? = nil) {
        httpMethod = method
        httpBody = payload

        if payload != nil {
            setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
