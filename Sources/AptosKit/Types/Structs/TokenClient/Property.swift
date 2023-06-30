//
//  Property.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UInt256
import Foundation

public struct Property: Hashable {
    public let name: String
    public let propertyType: String
    public let value: AnyHashable
    
    public static let BOOL: Int = 0
    public static let U8: Int = 1
    public static let U16: Int = 2
    public static let U32: Int = 3
    public static let U64: Int = 4
    public static let U128: Int = 5
    public static let U256: Int = 6
    public static let ADDRESS: Int = 7
    public static let BYTE_VECTOR: Int = 8
    public static let STRING: Int = 9
    
    public init(name: String, propertyType: String, value: AnyHashable) {
        self.name = name
        self.propertyType = propertyType
        self.value = value
    }
    
    public static func == (lhs: Property, rhs: Property) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.propertyType == rhs.propertyType &&
            lhs.value == rhs.value
    }
    
    public func serializeValue() throws -> Data {
        let ser = Serializer()
        
        if self.propertyType == "bool" {
            try Serializer.bool(ser, self.value as! Bool)
        } else if self.propertyType == "u8" {
            try Serializer.u8(ser, self.value as! UInt8)
        } else if self.propertyType == "u16" {
            try Serializer.u16(ser, self.value as! UInt16)
        } else if self.propertyType == "u32" {
            try Serializer.u32(ser, self.value as! UInt32)
        } else if self.propertyType == "u64" {
            try Serializer.u64(ser, self.value as! UInt64)
        } else if self.propertyType == "u128" {
            try Serializer.u128(ser, self.value as! UInt128)
        } else if self.propertyType == "u256" {
            try Serializer.u256(ser, self.value as! UInt256)
        } else if self.propertyType == "address" {
            try Serializer._struct(ser, value: self.value as! any KeyProtocol)
        } else if self.propertyType == "0x1::string::String" {
            try Serializer.str(ser, self.value as! String)
        } else if self.propertyType == "vector<u8>" {
            try Serializer.toBytes(ser, self.value as! Data)
        } else {
            throw InvalidPropertyType(propertyType: self.propertyType)
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
    
    public static func parse(_ name: String, _ propertyType: Int, _ value: Data) throws -> Property {
        let deserializer = Deserializer(data: value)
        
        if propertyType == Property.BOOL {
            return Property(name: name, propertyType: "bool", value: try deserializer.bool())
        } else if propertyType == Property.U8 {
            return Property(name: name, propertyType: "u8", value: try Deserializer.u8(deserializer))
        } else if propertyType == Property.U16 {
            return Property(name: name, propertyType: "u16", value: try Deserializer.u16(deserializer))
        } else if propertyType == Property.U32 {
            return Property(name: name, propertyType: "u32", value: try Deserializer.u32(deserializer))
        } else if propertyType == Property.U64 {
            return Property(name: name, propertyType: "u64", value: try Deserializer.u64(deserializer))
        } else if propertyType == Property.U128 {
            return Property(name: name, propertyType: "u128", value: try Deserializer.u128(deserializer))
        } else if propertyType == Property.U256 {
            return Property(name: name, propertyType: "u256", value: try Deserializer.u256(deserializer))
        } else if propertyType == Property.ADDRESS {
            return Property(name: name, propertyType: "address", value: try AccountAddress.deserialize(from: deserializer))
        } else if propertyType == Property.STRING {
            return Property(name: name, propertyType: "0x1::string::String", value: try Deserializer.string(deserializer))
        } else if propertyType == Property.BYTE_VECTOR {
            return Property(name: name, propertyType: "vector<u8>", value: try Deserializer.toBytes(deserializer))
        } else {
            throw InvalidPropertyType(propertyType: propertyType)
        }
    }
    
    public static func bool(_ name: String, _ value: Bool) -> Property {
        return Property(name: name, propertyType: "bool", value: value)
    }
    
    public static func u8(_ name: String, _ value: UInt8) -> Property {
        return Property(name: name, propertyType: "u8", value: value)
    }
    
    public static func u16(_ name: String, _ value: UInt16) -> Property {
        return Property(name: name, propertyType: "u16", value: value)
    }
    
    public static func u32(_ name: String, _ value: UInt32) -> Property {
        return Property(name: name, propertyType: "u32", value: value)
    }
    
    public static func u64(_ name: String, _ value: UInt64) -> Property {
        return Property(name: name, propertyType: "u64", value: value)
    }
    
    public static func u128(_ name: String, _ value: UInt128) -> Property {
        return Property(name: name, propertyType: "u128", value: value)
    }
    
    public static func u256(_ name: String, _ value: UInt256) -> Property {
        return Property(name: name, propertyType: "u256", value: value)
    }
    
    public static func string(_ name: String, _ value: String) -> Property {
        return Property(name: name, propertyType: "0x1::string::String", value: value)
    }
    
    public static func bytes(_ name: String, _ value: Data) -> Property {
        return Property(name: name, propertyType: "vector<u8>", value: value)
    }
}
