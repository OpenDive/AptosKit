//
//  File 8.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct AccountAddressTag: TypeProtcol, Equatable {
    let value: AccountAddress
    
    public static func ==(lhs: AccountAddressTag, rhs: AccountAddressTag) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func variant() -> Int {
        return TypeTag.accountAddress
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> AccountAddressTag {
        return try AccountAddressTag(value: deserializer._struct(type: AccountAddress.self))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.value)
    }
}
