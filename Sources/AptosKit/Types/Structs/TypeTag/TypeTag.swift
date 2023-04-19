//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct TypeTag: KeyProtocol, Equatable {
    public static let bool: Int = 0
    public static let u8: Int = 1
    public static let u64: Int = 2
    public static let u128: Int = 3
    public static let accountAddress: Int = 4
    public static let signer: Int = 5
    public static let vector: Int = 6
    public static let _struct: Int = 7
    public static let u16: Int = 8
    public static let u32: Int = 9
    public static let u256: Int = 10
    
    let value: any TypeProtcol
    
    public init(value: any TypeProtcol) {
        self.value = value
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TypeTag {
        let variant = try deserializer.uleb128()
        
        if variant == TypeTag.bool {
            return TypeTag(value: try BoolTag.deserialize(from: deserializer))
        } else if variant == TypeTag.u8 {
            return TypeTag(value: try U8Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u16 {
            return TypeTag(value: try U16Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u32 {
            return TypeTag(value: try U32Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u64 {
            return TypeTag(value: try U64Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u128 {
            return TypeTag(value: try U128Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.u256 {
            return TypeTag(value: try U256Tag.deserialize(from: deserializer))
        } else if variant == TypeTag.accountAddress {
            return TypeTag(value: try AccountAddressTag.deserialize(from: deserializer))
        } else if variant == TypeTag._struct {
            return TypeTag(value: try StructTag.deserialize(from: deserializer))
        } else {
            throw NSError(domain: "Not Implemented", code: -1)
        }
    }
    
    public static func == (lhs: TypeTag, rhs: TypeTag) -> Bool {
        return lhs.value.variant() == rhs.value.variant()
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(self.value.variant()))
        try Serializer._struct(serializer, value: self.value)
    }
}
