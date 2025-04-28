//
// Copyright (c) 2025 Actito. All rights reserved.
//

extension Bundle {
    public var applicationName: String {
        if let bundleDisplayName = infoDictionary?["CFBundleDisplayName"] as? String {
            return bundleDisplayName
        } else if let bundleName = infoDictionary?["CFBundleName"] as? String {
            return bundleName
        }

        return ""
    }

    public var applicationVersion: String {
        if let bundleShortVersion = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleShortVersion
        } else if let bundleVersion = object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return bundleVersion
        }

        return "1.0.0"
    }
}
