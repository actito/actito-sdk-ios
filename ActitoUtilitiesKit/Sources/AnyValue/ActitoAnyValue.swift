//
// Copyright (c) 2026 Actito. All rights reserved.
//

@propertyWrapper
public struct ActitoAnyValue {
    public var wrappedValue: Any

    public init(wrappedValue: Any) {
        self.wrappedValue = wrappedValue
    }
}

extension ActitoAnyValue: @unchecked Sendable {}

extension ActitoAnyValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.wrappedValue = NSNull()
            return
        }

        let boxed = try container.decode(ActitoAnyDecodable.self)
        self.wrappedValue = boxed.value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if wrappedValue is NSNull {
            try container.encodeNil()
            return
        }

        try container.encode(ActitoAnyEncodable(wrappedValue))
    }
}

extension ActitoAnyValue: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        ActitoAnyCodable(lhs.wrappedValue) == ActitoAnyCodable(rhs.wrappedValue)
    }
}
