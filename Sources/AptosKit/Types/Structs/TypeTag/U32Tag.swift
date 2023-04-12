//
//  File 4.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct U32Tag: TypeProtcol, Equatable {
    let value: Int
    
    public static func ==(lhs: U32Tag, rhs: U32Tag) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func variant() -> Int {
        return TypeTag.u32
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> U32Tag {
        return try U32Tag(value: Int(deserializer.u32()))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        serializer.u32(UInt32(self.value))
    }
}
