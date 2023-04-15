//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import Foundation
import UInt256

let MAX_U8 = UInt8.max
let MAX_U16 = UInt16.max
let MAX_U32 = UInt32.max
let MAX_U64 = UInt64.max
let MAX_U128 = UInt128.max
let MAX_U256 = UInt256.max

public class Deserializer {
    private var input: Data
    private var position: Int = 0

    public init(data: Data) {
        self.input = data
    }

    public func remaining() -> Int {
        return input.count - position
    }

    public func bool() throws -> Bool {
        let value = Int(try readInt(length: 1))
        switch value {
        case 0:
            return false
        case 1:
            return true
        default:
            throw NSError(domain: "Unexpected boolean value: \(value)", code: -1, userInfo: nil)
        }
    }

    public static func toBytes(_ deserializer: Deserializer) throws -> Data {
        let length = try deserializer.uleb128()
        return try deserializer.read(length: Int(length))
    }

    public func fixedBytes(length: Int) throws -> Data {
        return try read(length: length)
    }

    public func map<K, V>(keyDecoder: (Deserializer) throws -> K, valueDecoder: (Deserializer) throws -> V) throws -> [K: V] {
        let length = try uleb128()
        var values: [K: V] = [:]
        while values.count < length {
            let key = try keyDecoder(self)
            let value = try valueDecoder(self)
            values[key] = value
        }
        return values
    }

    public func sequence<T>(valueDecoder: (Deserializer) throws -> T) throws -> [T] {
        let length = try uleb128()
        var values: [T] = []
        while values.count < length {
            values.append(try valueDecoder(self))
        }
        return values
    }

    public static func string(_ deserializer: Deserializer) throws -> String {
        let data = try Deserializer.toBytes(deserializer)
        guard let result = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Failed to decode string from data", code: -1, userInfo: nil)
        }
        return result
    }

    public func _struct<T: KeyProtocol>(type: T.Type) throws -> T {
        return try T.deserialize(from: self)
    }

    public static func u8(_ deserializer: Deserializer) throws -> UInt8 {
        return UInt8(try deserializer.readInt(length: 1))
    }

    public static func u16(_ deserializer: Deserializer) throws -> UInt16 {
        return UInt16(try deserializer.readInt(length: 2))
    }

    public static func u32(_ deserializer: Deserializer) throws -> UInt32 {
        return UInt32(try deserializer.readInt(length: 4))
    }

    public static func u64(_ deserializer: Deserializer) throws -> UInt64 {
        return UInt64(try deserializer.readInt(length: 8))
    }

    public static func u128(_ deserializer: Deserializer) throws -> UInt128 {
        return UInt128(try deserializer.readInt(length: 16))
    }

    public static func u256(_ deserializer: Deserializer) throws -> UInt256 {
        let value = try deserializer.readInt(length: 32)
        guard let result = UInt256(String(value)) else {
            throw NSError(domain: "Invalid Data", code: -1)
        }
        return result
    }

    public func uleb128() throws -> UInt {
        var value: UInt = 0
        var shift: UInt = 0

        while value <= UInt(MAX_U32) {
            let byte = try readInt(length: 1)
            value |= (UInt(byte) & 0x7F) << shift
            if Int(byte) & 0x80 == 0 {
                break
            }
            shift += 7
        }

        if value > UInt128(MAX_U128) {
            throw NSError(domain: "Unexpectedly large uleb128 value", code: -1, userInfo: nil)
        }

        return value
    }

    private func read(length: Int) throws -> Data {
        guard position + length <= input.count else {
            throw NSError(domain: "Unexpected end of input. Requested: \(length), found: \(input.count - position)", code: -1, userInfo: nil)
        }
        let range = position ..< position + length
        let value = input.subdata(in: range)
        position += length
        return value
    }

    private func readInt(length: Int) throws -> any UnsignedInteger {
        let data = try read(length: length)
        
        if length == 1 {
            return data.withUnsafeBytes { $0.load(as: UInt8.self) }
        } else if length == 2 {
            return data.withUnsafeBytes { $0.load(as: UInt16.self) }
        } else if length == 4 {
            return data.withUnsafeBytes { $0.load(as: UInt32.self) }
        } else if length == 8 {
            return data.withUnsafeBytes { $0.load(as: UInt64.self) }
        } else if length == 16 {
            return data.withUnsafeBytes { $0.load(as: UInt128.self) }
        } else if length == 32 {
            return data.withUnsafeBytes { $0.load(as: UInt256.self) }
        } else {
            throw NSError(domain: "Invalid Length", code: -1)
        }
    }
}
