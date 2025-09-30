//
// Copyright (c) 2025 Actito. All rights reserved.
//

import CoreData

public enum ActitoDatabaseMergePolicy: Sendable {
    case overwrite

    public var policy: NSMergePolicy {
        switch self {
        case .overwrite: return NSMergePolicy.overwrite
        }
    }
}
