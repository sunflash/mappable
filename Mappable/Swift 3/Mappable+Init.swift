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

    /// `Mappable` object nested type info
    static var nestedTypeInfo: [String: Mappable.Type] {get}

    /// Init `Mappable` struct with a dictionary of json payload.
    init(type: Mappable.Type, dictionary: [String:Any], _ dateFormatter: DateFormatter?) throws

    /// Default requirement as part of the `Mappable` protocol, it's necessary when expose `Mappable` object through SDK framework.
    init()
}

extension Mappable {

    /// `Mappable` object nested type info, default is empty.
    public static var nestedTypeInfo: [String: Mappable.Type] {
        return [String: Mappable.Type]()
    }

    /// Init Mappable struct with a dictionary of json payload.
    ///
    /// - Parameters:
    ///   - dictionary: dictionary of data from json payload
    ///   - dateFormatter: date formatter for convert `Date String` to `Date`
    /// - Throws: `CocoaError(.coderValueNotFound)` if value not found, `ConstructionErrors` if data can't be map to mappable struct.
    public init(type: Mappable.Type, dictionary: [String:Any], _ dateFormatter: DateFormatter?) throws {

        do {

            self = try construct { property in

                guard var value = dictionary[property.key] else {
                    let emptyValue = Self.emptyValue(property.key, property.type, type.nestedTypeInfo)
                    logCoder(.JSONDecode, "Value for \(property.key) was not found, used empty value \(emptyValue)")
                    return emptyValue
                }

                let isDateType = (property.type is Optional<Date>.Type) || (property.type is Date.Type)
                if isDateType == true, let string = value as? String, let formatter = dateFormatter {
                    value = formatter.date(from: string) as Any
                }

                guard let nestedType = type.nestedTypeInfo[property.key] else {return value}

                if let nestedValue = value as? [String:Any] {
                    return try nestedType.init(type: nestedType, dictionary: nestedValue, dateFormatter)
                }

                if let nestedValueArray = value as? [[String:Any]] {
                    let values = try nestedValueArray.flatMap {try nestedType.init(type: nestedType, dictionary: $0, dateFormatter)}
                    return values
                }
                return value
            }

        } catch {

            if let constructionError = error as? ConstructionErrors {
                logCoder(.JSONDecode, constructionError.description)
            }
            throw error
        }
    }

    private static func emptyValue(_ key: String, _ type: Any.Type, _ nestedTypeInfo: [String: Mappable.Type] ) -> Any {

        if type is String.Type {return ""}
        if type is Int.Type || type is Float.Type || type is Double.Type {return 0}
        if type is Bool.Type {return false}

        if let nestedType = nestedTypeInfo[key], "\(type)".lowercased().contains("optional") == false {
            let isNestedArray = "\(type)".lowercased().contains("array")
            return isNestedArray ? [nestedType.init()] : nestedType.init()
        }
        return Optional<Any>.none as Any
    }
}

#endif
