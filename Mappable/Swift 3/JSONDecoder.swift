import Foundation

#if swift(>=4)
#elseif swift(>=3)

extension CocoaError.Code {
    /// Thrown when a value is corrupt or contain data in wrong format
    /// - Note: Emulated system error code when it's unavaiable for iOS 8.
    @available(iOS, introduced: 8.0, deprecated: 8.5)
    public static var coderReadCorrupt: CocoaError.Code {
        return CocoaError.Code(rawValue: 4864)
    }

    /// Thrown when a value is not found
    /// - Note: Emulated system error code when it's unavaiable for iOS 8.
    @available(iOS, introduced: 8.0, deprecated: 8.5)
    public static var coderValueNotFound: CocoaError.Code {
        return CocoaError.Code(rawValue: 4865)
    }

    /// Thrown when a value incompatible with the output format is encoded.
    /// - Note: Emulated system error code that is first available with swift 4 and iOS 11.
    public static var coderInvalidValue: CocoaError.Code {
        return CocoaError.Code(rawValue: 4866)
    }

    /// Thrown when a value of a given type is requested but the encountered value is of an incompatible type.
    /// - Note: Emulated system error code that is first available with swift 4 and iOS 11.
    public static var coderTypeMismatch: CocoaError.Code {
        return CocoaError.Code(rawValue: 4867)
    }
}

/// `JSONDecoder` facilitates the decoding of JSON into semantic `Decodable` types.
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

    /// Initializes `self` with default strategies.
    public init() {}

    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `CocoaError(.coderReadCorrupt)` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    public func decode<T: Mappable>(_ type: T.Type, from data: Data) throws -> T {

        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            logCoder(.JSONDecode, "json data is invalid")
            throw CocoaError(.coderReadCorrupt)
        }

        guard let jsonDict = json as? [String:Any] else {
            logCoder(.JSONDecode, "json object is not dictionary")
            throw CocoaError(.coderReadCorrupt)
        }

        switch dateDecodingStrategy {
        case .formatted(let formatter):
            return try type.init(dictionary: jsonDict, formatter)
        }
    }
}

#endif
