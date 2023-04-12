//
//  File 7.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation
import UInt256

public struct U256Tag: TypeProtcol, Equatable {
    let value: Int
    
    public static func ==(lhs: U256Tag, rhs: U256Tag) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func variant() -> Int {
        return TypeTag.u256
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> U256Tag {
        return try U256Tag(value: Int(Deserializer.u256(deserializer)))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        Serializer.u256(serializer, UInt256(self.value))
    }
}
