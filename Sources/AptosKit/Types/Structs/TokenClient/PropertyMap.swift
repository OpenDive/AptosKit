//
//  PropertyMap.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SwiftyJSON

public struct PropertyMap: ReadObjectProtocol {
    public let properties: [Property]
    
    public static let structTag: String = "0x4::property_map::PropertyMap"
    
    public init(properties: [Property]) {
        self.properties = properties
    }
    
    public func toTuple() throws -> ([String], [String], [Data]) {
        var names: [String] = []
        var types: [String] = []
        var values: [Data] = []
        
        for property in self.properties {
            names.append(property.name)
            types.append(property.propertyType)
            values.append(try property.serializeValue())
        }
        
        return (names, types, values)
    }
    
    public static func parse(_ resource: JSON) throws -> PropertyMap {
        let props = resource["inner"]["data"]
        var properties: [Property] = []
        
        for property in props.arrayValue {
            properties.append(
                Property(
                    name: property["key"].stringValue,
                    propertyType: property["value"]["type"].stringValue,
                    value: Data(
                        hex: "\(property["value"]["value"].stringValue.dropFirst(2))"
                    )
                )
            )
        }
        
        return PropertyMap(properties: properties)
    }
}
