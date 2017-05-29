//
//  JSONEncoder.swift
//  Mappable
//
//  Created by Min Wu on 25/05/2017.
//  Copyright © 2017 Min Wu. All rights reserved.
//

import Foundation

#if swift(>=4)
#elseif swift(>=3)

/// `JSONEncoder` facilitates the encoding of `Encodable` values into JSON.
public class JSONEncoder {

    /// The formatting of the output JSON data.
    public enum OutputFormatting {

        /// Produce JSON compacted by removing whitespace. This is the default formatting.
        case compact

        /// Produce human-readable JSON with indented output.
        case prettyPrinted
    }

    /// The strategy to use for encoding `Date` values.
    public enum DateEncodingStrategy {
        /// Encode the `Date` as a string formatted by the given formatter.
        case formatted(DateFormatter)
    }

    /// The output format to produce. Defaults to `.compact`.
    public var outputFormatting: JSONEncoder.OutputFormatting = .compact

    /// The strategy to use in encoding dates.
    open var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return DateEncodingStrategy.formatted(RFC3339DateFormatter)
    }()

    /// Initializes `self` with default strategies.
    public init() {}

    /// Encodes the given top-level value and returns its JSON representation.
    ///
    /// - parameter value: The value to encode.
    /// - returns: A new `Data` value containing the encoded JSON data.
    /// - throws: `CocoaError(.coderInvalidValue)` if a non-comforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - throws: An error if any value throws an error during encoding.
    public func encode<T: Mappable>(_ value: T) throws -> Data {

        var propertyUnwrappedDataRaw = value.propertyUnwrappedDataRaw
        propertyUnwrappedDataRaw = formatDateToString(propertyUnwrappedDataRaw)

        guard propertyUnwrappedDataRaw.isEmpty == false else {
            logCoder(.JSONDecode, "Can't extract json data")
            throw CocoaError(.coderValueNotFound)
        }

        let options: JSONSerialization.WritingOptions = (outputFormatting == .compact) ? [] : .prettyPrinted

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: propertyUnwrappedDataRaw, options: options)
            return jsonData
        } catch {
            logCoder(.JSONEncode, "Can't serilize json data")
            throw CocoaError(.coderInvalidValue)
        }
    }

    private func formatDateToString(_ dictionary: [String:Any]) -> [String:Any] {

        var results = [String: Any]()

        for (key, value) in dictionary {

            let type = type(of: value)

            let isDate = (type == Date.self) || (type == Optional<Date>.self)
            if isDate == true, let date = value as? Date,
                case let DateEncodingStrategy.formatted(formatter) = dateEncodingStrategy {
                let dateString = formatter.string(from: date)
                results[key] = dateString as Any
                continue
            }

            if let nestedDictionary = value as? [String:Any] {
                let result = formatDateToString(nestedDictionary)
                results[key] = result
                continue
            }
            results[key] = value
        }
        return results
    }
}

#endif
