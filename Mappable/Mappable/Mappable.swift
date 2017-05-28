//
//  Mappable.swift
//  Mappable
//
//  Created by Min Wu on 22/05/2017.
//  Copyright © 2017 Min Wu. All rights reserved.
//

import Foundation

// MARK: - Mappable Protocol

#if swift(>=4)

public protocol Mappable: Codable {

    var propertyValues: [String: Any] {get}

    init()
}
#endif

// MARK: - Mappable Property Raw Data

extension Mappable {

    public var propertyNamesRaw: [String] {
        return Mirror(reflecting: self).children.flatMap {$0.label}
    }

    public var propertyValuesRaw: [String:Any] {

        var values = [String: Any]()
        let properties = Mirror(reflecting: self).children

        for property in properties {
            guard let propertyName = property.label else {continue}
            values[propertyName] = property.value
        }
        return values
    }

    public var propertyUnwrappedDataRaw: [String:Any] {
        return unwrapPropertyValues(propertyValuesRaw, true)
    }

    public var objectDescriptionRaw: String {
        return generateObjectDescription(showRawDescription: true)
    }
}

// MARK: - Mappable Property Data

extension Mappable {

    public var objectInfo: String {
        let mirror = Mirror(reflecting: self)
        if let styleDescription = mirror.displayStyle?.description {
            return "\(mirror.subjectType): \(styleDescription)"
        } else {
            return "\(mirror.subjectType)"
        }
    }

    public var propertyNames: [String] {
        return propertyValues.flatMap {$0.key}
    }

    public var propertyUnwrappedData: [String:Any] {
        return unwrapPropertyValues(propertyValues, false)
    }

    public var objectDescription: String {
        return generateObjectDescription(showRawDescription: false)
    }
}

// MARK: - Mappable Property Methods

extension Mappable {

    public subscript (key: String) -> Any? {
        return propertyValues[key] ?? propertyValuesRaw[key]
    }

    private func propertyValuesRaw(excluded property: [String]) -> [String:Any] {
        var values = [String: Any]()
        propertyValuesRaw.filter {property.contains($0.key) == false}.forEach {values[$0.key] = $0.value}
        return values
    }

    public func adjustPropertyValues(excluded property: [String] = [""],
                                     additional propertyInfo: [String:Any] = [String: Any]()) -> [String:Any] {
        var values = propertyValuesRaw(excluded: property)
        values += propertyInfo
        return values
    }
}

// MARK: - Mappable Nested Object

extension Mappable {

    fileprivate func processDataInNestedStructure<T>(type: T.Type, value: Any, action: (T) -> Any) -> (isNestedObject: Bool, data: Any?) {

        if let nestedObject = value as? T {
            let results = action(nestedObject)
            return (true, results)
        }

        if let nestedObjectArray = value as? [T] {
            var results = [Any]()
            for nestedObject in nestedObjectArray {
                let result = action(nestedObject)
                results.append(result)
            }
            return (true, results)
        }
        return (false, nil)
    }
}

// MARK: - Mappable Property JSON Representation

extension Mappable {

    public func propertyJSONRepresentation(dateFormatter: DateFormatter) -> String {
        return generateObjectJsonRepresentation(propertyUnwrappedDataRaw, dateFormatter)
    }

    private func generateObjectJsonRepresentation(_ unwrappedPropertyValues: [String:Any], _ dateFormatter: DateFormatter) -> String {

        let errorMessage = "Can't generate \(objectInfo) json representation."

        do {
            let jsonObject = formatDateToString(unwrappedPropertyValues, dateFormatter)
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? errorMessage
        } catch {
            logCoder(.JSONDecode, errorMessage)
            return errorMessage
        }
    }

    private func formatDateToString(_ dictionary: [String:Any], _ dateFormatter: DateFormatter) -> [String:Any] {

        var results = [String: Any]()

        for (key, value) in dictionary {

            let type = Mirror(reflecting: value).subjectType

            let isDate = (type == Date.self) || (type == Optional<Date>.self)
            if isDate == true, let date = value as? Date {
                let dateString = dateFormatter.string(from: date)
                results[key] = dateString as Any
                continue
            }

            let result = processDataInNestedStructure(type: [String: Any].self, value: value) { nestedDictionary in
                return formatDateToString(nestedDictionary, dateFormatter)
            }
            if result.isNestedObject == true {
                results[key] = result.data
                continue
            }

            results[key] = value
        }
        return results
    }
}

// MARK: - Mappable Description Methods

extension Mappable {

    fileprivate func generateObjectDescription(showRawDescription: Bool) -> String {

        let values = (showRawDescription == true) ? propertyValuesRaw : propertyValues
        let sortedValues = values.sorted(by: {$0.key < $1.key})
        let propertyInfo = sortedValues.reduce("") {$0 + "\n\($1.key) = \(unwrappedDescription($1.value, showRawDescription))"}

        var descriptionString = separatorWithNewLine()
        descriptionString += objectInfo
        if showRawDescription == true {
            descriptionString += "\n" + "RAW"
        }
        descriptionString += separatorWithNewLine()
        descriptionString += propertyInfo
        descriptionString += separatorWithNewLine("=")
        return descriptionString
    }

    private func unwrappedDescription(_ value: Any, _ useRawValue: Bool) -> String {
        let mirror = Mirror(reflecting: value)

        let result = processDataInNestedStructure(type: Mappable.self, value: value) { mappable in
            let nestedValues = (useRawValue == true) ? mappable.propertyValuesRaw : mappable.propertyValues
            let sortedValues = nestedValues.sorted(by: {$0.key < $1.key})
            let nestedUnwrapDescriptions = sortedValues.map {"\($0.key) = \(unwrappedDescription($0.value, useRawValue))"}
            let nestedObjectDescription = nestedUnwrapDescriptions.joined(separator: ", ")
            return "{ \(nestedObjectDescription) }"
        }

        if result.isNestedObject == true {
            if let description = result.data as? String {
                return description
            } else if let descriptions = result.data as? [String] {
                return "[ \(descriptions.joined(separator: ",\n\t\t")) ]"
            }
        }

        guard let style = mirror.displayStyle, style == .optional else {return String(describing: value)}
        guard let first = mirror.children.first else {return "nil"}
        return String(describing:first.value)
    }
}

// MARK: - Mappabel Unwrap Values Methods

extension Mappable {

    fileprivate func unwrapPropertyValues(_ values: [String:Any], _ useRawValue: Bool) -> [String:Any] {
        var unwrappedValues = [String: Any]()
        for (key, value) in values {
            guard let validValue = unwrapPropertyValue(value, useRawValue) else {continue}
            unwrappedValues[key] = validValue
        }
        return unwrappedValues
    }

    private func unwrapPropertyValue(_ value: Any, _ useRawValue: Bool) -> Any? {
        let mirror = Mirror(reflecting: value)

        let result = processDataInNestedStructure(type: Mappable.self, value: value) { mappable in
            let values = (useRawValue == true) ? mappable.propertyValuesRaw : mappable.propertyValues
            let nestedValues = unwrapPropertyValues(values, useRawValue)
            return nestedValues
        }

        if result.isNestedObject == true {return result.data}

        guard let style = mirror.displayStyle, style == .optional else {return value}
        return mirror.children.first?.value
    }
}

// MARK: - Mirror Types Extension

extension Mirror.DisplayStyle {

    public var description: String {

        switch self {
        case .class:
            return "Class"
        case .collection:
            return "Collection"
        case .dictionary:
            return "Dictionary"
        case .enum:
            return "Enum"
        case .optional:
            return "Optional"
        case .set:
            return "Set"
        case .struct:
            return "Struct"
        case .tuple:
            return "Tuple"
        }
    }
}
