//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

extension Notification.Name {
    // Core
    internal static let actitoStatus = Notification.Name(rawValue: "app.actito_launched")

    // Geo
    internal static let locationUpdated = Notification.Name(rawValue: "app.location_updated")
    internal static let regionEntered = Notification.Name(rawValue: "app.region_enter")
    internal static let regionExited = Notification.Name(rawValue: "app.region_exit")
    internal static let beaconsRanged = Notification.Name(rawValue: "app.beacons_ranged")
}
