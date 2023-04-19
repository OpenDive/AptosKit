//
//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct BoolTag: TypeProtcol, Equatable {
    let value: Bool
    
    public static func ==(lhs: BoolTag, rhs: BoolTag) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func variant() -> Int {
        return TypeTag.bool
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> BoolTag {
        return try BoolTag(value: deserializer.bool())
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.bool(serializer, self.value)
    }
}
