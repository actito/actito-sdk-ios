//
// Copyright (c) 2025 Actito. All rights reserved.
//

import CryptoKit
import Foundation
import OSLog

internal enum QualifioSecureToken {
    private static let subject = "actito-sample-user"

    private static let formFields = [
        "firstname": "John",
        "lastname": "Doe",
        "email": "john.doe@example.com",
    ]

    internal static func generate(for campaign: String) -> String? {
        guard let secret = loadSecret() else {
            Logger.main.warning("Qualifio secure token secret not configured. Loading campaign '\(campaign)' without a token.")
            return nil
        }

        let now = Int(Date().timeIntervalSince1970)

        let header: [String: Any] = [
            "alg": "HS256",
            "typ": "JWT",
        ]

        let payload: [String: Any] = [
            "sub": subject,
            "iat": now,
            "nbf": now - 5 * 60,
            "exp": now + 60 * 60,
            "form": formFields,
        ]

        do {
            let encodedHeader = try JSONSerialization.data(withJSONObject: header).base64URLEncodedString()
            let encodedPayload = try JSONSerialization.data(withJSONObject: payload).base64URLEncodedString()
            let signingInput = "\(encodedHeader).\(encodedPayload)"

            let signature = HMAC<SHA256>.authenticationCode(
                for: Data(signingInput.utf8),
                using: SymmetricKey(data: Data(secret.utf8))
            )

            return "\(signingInput).\(Data(signature).base64URLEncodedString())"
        } catch {
            Logger.main.error("Failed to generate the Qualifio secure token for campaign '\(campaign)'. \(error)")
            return nil
        }
    }

    private static func loadSecret() -> String? {
        guard let url = Bundle.main.url(forResource: "QualifioSecrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let secret = plist["secureTokenSecret"] as? String,
              !secret.isEmpty
        else {
            return nil
        }

        return secret
    }
}

extension Data {
    fileprivate func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
