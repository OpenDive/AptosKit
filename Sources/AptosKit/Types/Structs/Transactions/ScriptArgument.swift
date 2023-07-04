//
//  ScriptArgument.swift
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

import Foundation
import UInt256

/// Aptos Blockchain Script Argument
public struct ScriptArgument: KeyProtocol, Equatable {
    /// UInt8 Variant
    public static let u8: UInt8 = 0

    /// UInt64 Variant
    public static let u64: UInt8 = 1

    /// UInt128 Variant
    public static let u128: UInt8 = 2

    /// AccountAddress Variant
    public static let address: UInt8 = 3

    /// Vector Variant
    public static let u8Vector: UInt8 = 4

    /// Boolean Variant
    public static let bool: UInt8 = 5

    /// UInt16 Variant
    public static let u16: UInt8 = 6

    /// UInt32 Variant
    public static let u32: UInt8 = 7

    /// UInt256 Variant
    public static let u256: UInt8 = 8

    /// The variant value itself
    public var variant: UInt8

    /// The value itself
    public var value: Any

    public init(_ variant: UInt8, _ value: Any) throws {
        if variant < 0 || variant > 5 {
            throw AptosError.invalidVariant
        }

        self.variant = variant
        self.value = value
    }

    public static func == (lhs: ScriptArgument, rhs: ScriptArgument) -> Bool {
        if lhs.variant != rhs.variant { return false }

        if lhs.value is UInt8 && rhs.value is UInt8 {
            let lhsValue = lhs.value as! UInt8
            let rhsValue = rhs.value as! UInt8
            return lhsValue == rhsValue
        } else if lhs.value is UInt16 && rhs.value is UInt16 {
            let lhsValue = lhs.value as! UInt16
            let rhsValue = rhs.value as! UInt16
            return lhsValue == rhsValue
        } else if lhs.value is UInt32 && rhs.value is UInt32 {
            let lhsValue = lhs.value as! UInt32
            let rhsValue = rhs.value as! UInt32
            return lhsValue == rhsValue
        } else if lhs.value is UInt64 && rhs.value is UInt64 {
            let lhsValue = lhs.value as! UInt64
            let rhsValue = rhs.value as! UInt64
            return lhsValue == rhsValue
        } else if lhs.value is UInt128 && rhs.value is UInt128 {
            let lhsValue = lhs.value as! UInt128
            let rhsValue = rhs.value as! UInt128
            return lhsValue == rhsValue
        } else if lhs.value is UInt256 && rhs.value is UInt256 {
            let lhsValue = lhs.value as! UInt256
            let rhsValue = rhs.value as! UInt256
            return lhsValue == rhsValue
        } else if lhs.value is Bool && rhs.value is Bool {
            let lhsValue = lhs.value as! Bool
            let rhsValue = rhs.value as! Bool
            return lhsValue == rhsValue
        } else if lhs.value is Data && rhs.value is Data {
            let lhsValue = lhs.value as! Data
            let rhsValue = rhs.value as! Data
            return lhsValue == rhsValue
        } else if lhs.value is any KeyProtocol && rhs.value is any KeyProtocol {
            let lhsValue = lhs.value as! any KeyProtocol
            let rhsValue = rhs.value as! any KeyProtocol
            let lhsSer = Serializer()
            let rhsSer = Serializer()

            do {
                try Serializer._struct(lhsSer, value: lhsValue)
                try Serializer._struct(rhsSer, value: rhsValue)
            } catch {
                return false
            }

            return lhsSer.output() == rhsSer.output()
        } else {
            return false
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ScriptArgument {
        let variant = try Deserializer.u8(deserializer)
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
            throw AptosError.invalidVariant
        }

        return try ScriptArgument(variant, value)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u8(serializer, self.variant)

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
        } else if self.variant == ScriptArgument.address {
             try Serializer._struct(serializer, value: self.value as! AccountAddress)
        } else if self.variant == ScriptArgument.u8Vector {
            try Serializer.toBytes(serializer, self.value as! Data)
        } else if self.variant == ScriptArgument.bool {
            try Serializer.bool(serializer, self.value as! Bool)
        } else {
            throw AptosError.invalidVariant
        }
    }
}
