//
//  Mappable+Extension.swift
//  Mappable
//
//  Created by Min Wu on 25/05/2017.
//  Copyright © 2017 Min Wu. All rights reserved.
//

import Foundation

#if swift(>=4)
#elseif swift(>=3)
import Reflection

/// Mappable protocol that provides extra functionality to mapped object.
public protocol Mappable {

    /// `Mappable` object's property value.
    var propertyValues: [String: Any] {get}

    /// Init `Mappable` struct with a dictionary of json payload.
    init(dictionary: [String:Any], _ dateFormatter: DateFormatter?) throws

    /// Default requirement as part of the `Mappable` protocol, it's necessary when expose `Mappable` object through SDK framework.
    init()
}

extension Mappable {

    /// Init Mappable struct with a dictionary of json payload.
    ///
    /// - Parameters:
    ///   - dictionary: dictionary of data from json payload
    ///   - dateFormatter: date formatter for convert `Date String` to `Date`
    /// - Throws: `CocoaError(.coderValueNotFound)` if value not found, `ConstructionErrors` if data can't be map to mappable struct.
    public init(dictionary: [String:Any], _ dateFormatter: DateFormatter?) throws {

        do {

            self = try construct { property in

                guard var value = dictionary[property.key] else {
                    logCoder(.JSONDecode, "Value for \(property.key) was not found")
                    throw CocoaError(.coderValueNotFound)
                }

                let isDateType = (property.type is Optional<Date>.Type) || (property.type is Date.Type)
                if isDateType == true, let string = value as? String, let formatter = dateFormatter {
                    value = formatter.date(from: string) as Any
                }

                guard let nestedType = property.type as? Mappable.Type,
                    let nestedValue = value as? [String:Any] else {
                        return value
                }

                return try nestedType.init(dictionary: nestedValue, dateFormatter)
            }

        } catch {

            if let constructionError = error as? ConstructionErrors {
                logCoder(.JSONDecode, constructionError.description)
            }
            throw error
        }
    }
}

#endif
