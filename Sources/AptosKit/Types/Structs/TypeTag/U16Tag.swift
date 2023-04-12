//
//  File 3.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct U16Tag: TypeProtcol, Equatable {
    let value: Int
    
    public static func ==(lhs: U16Tag, rhs: U16Tag) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func variant() -> Int {
        return TypeTag.u16
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> U16Tag {
        return try U16Tag(value: Int(deserializer.u16()))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        serializer.u16(UInt16(self.value))
    }
}
