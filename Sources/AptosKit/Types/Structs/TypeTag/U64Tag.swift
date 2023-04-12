//
//  File 5.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct U64Tag: TypeProtcol, Equatable {
    let value: Int
    
    public static func ==(lhs: U64Tag, rhs: U64Tag) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func variant() -> Int {
        return TypeTag.u64
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> U64Tag {
        return try U64Tag(value: Int(Deserializer.u64(deserializer)))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        Serializer.u64(serializer, UInt64(self.value))
    }
}