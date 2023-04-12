//
//  File 2.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct U8Tag: TypeProtcol, Equatable {
    let value: Int
    
    public static func ==(lhs: U8Tag, rhs: U8Tag) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func variant() -> Int {
        return TypeTag.u8
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> U8Tag {
        return try U8Tag(value: Int(Deserializer.u8(deserializer)))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        Serializer.u8(serializer, UInt8(self.value))
    }
}
