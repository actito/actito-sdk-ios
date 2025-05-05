//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

internal enum ActitoLaunchState: Int {
    case none
    case configured
    case launching
    case ready
}

extension ActitoLaunchState: Comparable {
    public static func < (lhs: ActitoLaunchState, rhs: ActitoLaunchState) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public static func <= (lhs: ActitoLaunchState, rhs: ActitoLaunchState) -> Bool {
        lhs.rawValue <= rhs.rawValue
    }

    public static func >= (lhs: ActitoLaunchState, rhs: ActitoLaunchState) -> Bool {
        lhs.rawValue >= rhs.rawValue
    }

    public static func > (lhs: ActitoLaunchState, rhs: ActitoLaunchState) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}
