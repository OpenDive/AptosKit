//
//  File 6.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct U128Tag: TypeProtcol, Equatable {
    let value: Int
    
    public static func ==(lhs: U128Tag, rhs: U128Tag) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func variant() -> Int {
        return TypeTag.u128
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> U128Tag {
        return try U128Tag(value: Int(Deserializer.u128(deserializer)))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        Serializer.u128(serializer, UInt128(self.value))
    }
}
