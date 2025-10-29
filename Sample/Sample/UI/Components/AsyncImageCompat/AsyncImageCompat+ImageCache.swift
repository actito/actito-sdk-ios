//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

internal protocol ImageCache: Sendable {
    subscript(_: URL) -> UIImage? { get set }
}

internal struct TemporaryImageCache: ImageCache, @unchecked Sendable {
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()

    internal subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

internal struct ImageCacheKey: EnvironmentKey {
    internal static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    internal var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
