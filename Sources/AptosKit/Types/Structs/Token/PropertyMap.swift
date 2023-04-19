//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation
import SwiftyJSON

public struct PropertyMap: CustomStringConvertible {
    var properties: [Property]
    
    let structTag: String = "0x4::property_map::PropertyMap"
    
    init(properties: [Property]) {
        self.properties = properties
    }
    
    public var description: String {
        var response = "PropertyMap["
        
        for prop in self.properties {
            response += "\(prop.description), "
        }
        
        if self.properties.count > 0 {
            response = String(response.dropLast(2))
        }
        
        response += "]"
        return response
    }
    
    public func toTuple() throws -> ([String], [String], [Data]) {
        var names: [String] = []
        var types: [String] = []
        var values: [Data] = []
        
        for property in properties {
            names.append(property.name)
            types.append(property.propertyType)
            values.append(try property.serializeValue())
        }
        
        return (names, types, values)
    }
    
    public static func parse(_ resource: JSON) throws -> PropertyMap {
        let props = resource["inner"]["data"].arrayValue
        var properties: [Property] = []
        
        for prop in props {
            properties.append(
                try Property.parse(
                    prop["key"].stringValue,
                    prop["value"]["type"].intValue,
                    Data(hex: prop["value"]["value"].stringValue)
                )
            )
        }
        
        return PropertyMap(properties: properties)
    }
}
