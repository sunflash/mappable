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

public protocol Mappable {

    var propertyValues: [String: Any] {get}

    init(dictionary: [String:Any], _ dateFormatter: DateFormatter?) throws

    init()
}

@available(swift, deprecated: 4)
extension Mappable {

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
