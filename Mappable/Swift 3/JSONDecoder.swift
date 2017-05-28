import Foundation

#if swift(>=4)
#elseif swift(>=3)

extension CocoaError.Code {
    /// Thrown when a value incompatible with the output format is encoded.
    public static var coderInvalidValue: CocoaError.Code {
        return CocoaError.Code(rawValue: 4866)
    }

    /// Thrown when a value of a given type is requested but the encountered value is of an incompatible type.
    public static var coderTypeMismatch: CocoaError.Code {
        return CocoaError.Code(rawValue: 4867)
    }
}

public class JSONDecoder {

    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy {
        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)
    }

    /// The strategy to use in decoding dates.
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return DateDecodingStrategy.formatted(RFC3339DateFormatter)
    }()

    public init() {}

    public func decode<T: Mappable>(_ type: T.Type, from data: Data) throws -> T {

        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            logCoder(.JSONDecode, "json data is invalid")
            throw CocoaError(.coderValueNotFound)
        }

        guard let jsonDict = json as? [String:Any] else {
            logCoder(.JSONDecode, "json object is not dicationary")
            throw CocoaError(.coderInvalidValue)
        }

        switch dateDecodingStrategy {
        case .formatted(let formatter):
            return try type.init(dictionary: jsonDict, formatter)
        }
    }
}

#endif
