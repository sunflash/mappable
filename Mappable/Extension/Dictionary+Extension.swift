//
//  Dictionary+Extension.swift
//  Mappable
//
//  Created by Min Wu on 23/05/2017.
//  Copyright © 2017 Min Wu. All rights reserved.
//

import Foundation

extension Dictionary {

    static public func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        for (key, value) in rhs {
            result[key] = value
        }
        return result
    }

    static public func += (left: inout [Key:Value], right: [Key:Value]) {
        right.forEach {left[$0.key] = $0.value}
    }
}
