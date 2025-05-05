//
// Copyright (c) 2025 Actito. All rights reserved.
//

extension JSONDecoder {
    public static var actito: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Date.isoDateParser)

        return decoder
    }
}

extension JSONEncoder {
    public static var actito: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Date.isoDateFormatter)

        return encoder
    }
}
