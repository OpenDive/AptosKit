//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation
import UInt256

public struct ScriptArgument: KeyProtocol {
    public static let u8: Int = 0
    public static let u64: Int = 1
    public static let u128: Int = 2
    public static let address: Int = 3
    public static let u8Vector: Int = 4
    public static let bool: Int = 5
    public static let u16: Int = 6
    public static let u32: Int = 7
    public static let u256: Int = 8
    
    public var variant: Int
    public var value: Any
    
    init(variant: Int, value: Any) throws {
        if variant < 0 || variant > 5 {
            throw NSError(domain: "Invalid Variant", code: -1)
        }
        
        self.variant = variant
        self.value = value
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ScriptArgument {
        let variant = Int(try Deserializer.u8(deserializer))
        let value: Any
        
        if variant == ScriptArgument.u8 {
            value = try Deserializer.u8(deserializer)
        } else if variant == ScriptArgument.u16 {
            value = try Deserializer.u16(deserializer)
        } else if variant == ScriptArgument.u32 {
            value = try Deserializer.u32(deserializer)
        } else if variant == ScriptArgument.u64 {
            value = try Deserializer.u64(deserializer)
        } else if variant == ScriptArgument.u128 {
            value = try Deserializer.u128(deserializer)
        } else if variant == ScriptArgument.u256 {
            value = try Deserializer.u256(deserializer)
        } else if variant == ScriptArgument.address {
            value = try AccountAddress.deserialize(from: deserializer)
        } else if variant == ScriptArgument.u8Vector {
            value = try Deserializer.toBytes(deserializer)
        } else if variant == ScriptArgument.bool {
            value = try deserializer.bool()
        } else {
            throw NSError(domain: "Invalid Variant", code: -1)
        }
        
        return try ScriptArgument(variant: variant, value: value)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u8(serializer, UInt8(self.variant))
        
        if self.variant == ScriptArgument.u8 {
            try Serializer.u8(serializer, self.value as! UInt8)
        } else if self.variant == ScriptArgument.u16 {
            try Serializer.u16(serializer, self.value as! UInt16)
        } else if self.variant == ScriptArgument.u32 {
            try Serializer.u32(serializer, self.value as! UInt32)
        } else if self.variant == ScriptArgument.u64 {
            try Serializer.u64(serializer, self.value as! UInt64)
        } else if self.variant == ScriptArgument.u128 {
            try Serializer.u128(serializer, self.value as! UInt128)
        } else if self.variant == ScriptArgument.u256 {
            try Serializer.u256(serializer, self.value as! UInt256)
        } else if self.variant == ScriptArgument.address && self.value.self is KeyProtocol.Type {
             try Serializer._struct(serializer, value: self.value as! KeyProtocol)
        } else if self.variant == ScriptArgument.u8Vector {
            try Serializer.toBytes(serializer, self.value as! Data)
        } else if self.variant == ScriptArgument.bool {
            serializer.bool(self.value as! Bool)
        }
    }
}
