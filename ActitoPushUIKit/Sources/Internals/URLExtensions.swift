//
// Copyright (c) 2025 Actito. All rights reserved.
//

extension URL {
    internal var isHttpUrl: Bool {
        scheme == "http" || scheme == "https"
    }
}
