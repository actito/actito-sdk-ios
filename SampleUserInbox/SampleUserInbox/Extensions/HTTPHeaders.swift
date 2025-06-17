//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Alamofire

extension HTTPHeaders {
    internal static func authorizationHeader(accessToken: String) -> HTTPHeaders {
        return [
            "Authorization": "Bearer \(accessToken)"
        ]
    }
}
