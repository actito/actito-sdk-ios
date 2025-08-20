//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation
import UIKit

public class ActitoImageCache {
    private let session = URLSession(configuration: .default)

    public private(set) var portraitImage: UIImage?
    public private(set) var landscapeImage: UIImage?

    @MainActor
    public var orientationConstrainedImage: UIImage? {
        if UIDevice.current.orientation.isLandscape {
            return landscapeImage ?? portraitImage
        }

        return portraitImage ?? landscapeImage
    }

    internal func preloadImages(for message: ActitoInAppMessage) async throws {
        self.portraitImage = nil
        self.landscapeImage = nil

        if let urlStr = message.image, let url = URL(string: urlStr) {
            let (data, _) = try await session.data(from: url)

            guard let image = UIImage(data: data) else {
                throw Error.invalidImage
            }

            portraitImage = image
        }

        if let urlStr = message.landscapeImage, let url = URL(string: urlStr) {
            let (data, _) = try await session.data(from: url)

            guard let image = UIImage(data: data) else {
                throw Error.invalidImage
            }

            landscapeImage = image
        }
    }

    public enum Error: Swift.Error {
        case invalidImage
    }
}
