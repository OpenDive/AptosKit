//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation
import UInt256

public struct Property: CustomStringConvertible {
    public let name: String
    public let propertyType: String
    public let value: any EncodingProtocol
    
    static public let BOOL: Int = 0
    static public let U8: Int = 1
    static public let U16: Int = 2
    static public let U32: Int = 3
    static public let U64: Int = 4
    static public let U128: Int = 5
    static public let U256: Int = 6
    static public let ADDRESS: Int = 7
    static public let BYTE_VECTOR: Int = 8
    static public let STRING: Int = 9
    
    public init(
        name: String,
        propertyType: String,
        value: any EncodingProtocol
    ) {
        self.name = name
        self.propertyType = propertyType
        self.value = value
    }
    
    public var description: String {
        return "Property[\(self.name), \(self.propertyType), \(self.value)]"
    }
    
    public func serializeValue() throws -> Data {
        let ser = Serializer()
        
        if self.propertyType == "bool" {
            try Serializer.bool(ser, self.value)
        } else if self.propertyType == "u8" {
            try Serializer.u8(ser, self.value)
        } else if self.propertyType == "u16" {
            try Serializer.u16(ser, self.value)
        } else if self.propertyType == "u32" {
            try Serializer.u32(ser, self.value)
        } else if self.propertyType == "u64" {
            try Serializer.u64(ser, self.value)
        } else if self.propertyType == "u128" {
            try Serializer.u128(ser, self.value)
        } else if self.propertyType == "u256" {
            try Serializer.u256(ser, self.value)
        } else if self.propertyType == "address" {
            try Serializer._struct(ser, value: self.value)
        } else if self.propertyType == "0x1::string::String" {
            try Serializer.str(ser, self.value)
        } else if self.propertyType == "vector<u8>" {
            try Serializer.toBytes(ser, self.value)
        } else {
            throw NSError(domain: "Invalid Property Type", code: -1)
        }
        
        return ser.output()
    }
    
    public func toTransactionArguments() throws -> [AnyTransactionArgument] {
        return [
            AnyTransactionArgument(TransactionArgument(value: self.name, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: self.propertyType, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: try self.serializeValue(), encoder: Serializer.toBytes))
        ]
    }
    
    public static func parse(
        _ name: String,
        _ propertyType: Int,
        _ value: Data
    ) throws -> Property {
        let der = Deserializer(data: value)
        
        if propertyType == Property.BOOL {
            return Property(name: name, propertyType: "bool", value: try der.bool())
        } else if propertyType == Property.U8 {
            return Property(name: name, propertyType: "u8", value: try Deserializer.u8(der))
        } else if propertyType == Property.U16 {
            return Property(name: name, propertyType: "u16", value: try Deserializer.u16(der))
        } else if propertyType == Property.U32 {
            return Property(name: name, propertyType: "u32", value: try Deserializer.u32(der))
        } else if propertyType == Property.U64 {
            return Property(name: name, propertyType: "u64", value: try Deserializer.u64(der))
        } else if propertyType == Property.U128 {
            return Property(name: name, propertyType: "u128", value: try Deserializer.u128(der))
        } else if propertyType == Property.U256 {
            return Property(name: name, propertyType: "u256", value: try Deserializer.u256(der))
        } else if propertyType == Property.ADDRESS {
            return Property(name: name, propertyType: "address", value: try AccountAddress.deserialize(from: der))
        } else if propertyType == Property.STRING {
            return Property(name: name, propertyType: "0x1::string::String", value: try Deserializer.string(der))
        } else if propertyType == Property.BYTE_VECTOR {
            return Property(name: name, propertyType: "vector<u8>", value: try Deserializer.toBytes(der))
        } else {
            throw NSError(domain: "Invalid Property Type", code: -1)
        }
    }
    
    public static func bool(name: String, value: Bool) -> Property {
        return Property(name: name, propertyType: "bool", value: value)
    }
    
    public static func u8(name: String, value: UInt8) -> Property {
        return Property(name: name, propertyType: "u8", value: value)
    }
    
    public static func u16(name: String, value: UInt16) -> Property {
        return Property(name: name, propertyType: "u16", value: value)
    }
    
    public static func u32(name: String, value: UInt32) -> Property {
        return Property(name: name, propertyType: "u32", value: value)
    }
    
    public static func u64(name: String, value: UInt64) -> Property {
        return Property(name: name, propertyType: "u64", value: value)
    }
    
    public static func u128(name: String, value: UInt128) -> Property {
        return Property(name: name, propertyType: "u128", value: value)
    }
    
    public static func u256(name: String, value: UInt256) -> Property {
        return Property(name: name, propertyType: "u256", value: value)
    }
    
    public static func string(name: String, value: String) -> Property {
        return Property(name: name, propertyType: "0x1::string::String", value: value)
    }
    
    public static func bytes(name: String, value: Data) -> Property {
        return Property(name: name, propertyType: "vector<u8>", value: value)
    }
}
