//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

public struct ActitoVisit: Codable, Equatable {
    public let departureDate: Date
    public let arrivalDate: Date
    public let latitude: Double
    public let longitude: Double

    public init(departureDate: Date, arrivalDate: Date, latitude: Double, longitude: Double) {
        self.departureDate = departureDate
        self.arrivalDate = arrivalDate
        self.latitude = latitude
        self.longitude = longitude
    }
}

// JSON: ActitoVisit
extension ActitoVisit {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoVisit {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoVisit.self, from: data)
    }
}
