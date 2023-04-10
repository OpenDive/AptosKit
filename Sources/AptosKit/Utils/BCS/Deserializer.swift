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

    init(data: Data) {
        self.input = data
    }

    func remaining() -> Int {
        return input.count - position
    }

    func bool() throws -> Bool {
        let value = try readInt(length: 1)
        switch value {
        case 0:
            return false
        case 1:
            return true
        default:
            throw NSError(domain: "Unexpected boolean value: \(value)", code: -1, userInfo: nil)
        }
    }

    func toBytes() throws -> Data {
        let length = try uleb128()
        return try read(length: length)
    }

    func fixedBytes(length: Int) throws -> Data {
        return try read(length: length)
    }

    func map<K, V>(keyDecoder: (Deserializer) throws -> K, valueDecoder: (Deserializer) throws -> V) throws -> [K: V] {
        let length = try uleb128()
        var values: [K: V] = [:]
        while values.count < length {
            let key = try keyDecoder(self)
            let value = try valueDecoder(self)
            values[key] = value
        }
        return values
    }

    func sequence<T>(valueDecoder: (Deserializer) throws -> T) throws -> [T] {
        let length = try uleb128()
        var values: [T] = []
        while values.count < length {
            values.append(try valueDecoder(self))
        }
        return values
    }

    func string() throws -> String {
        let data = try toBytes()
        guard let result = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Failed to decode string from data", code: -1, userInfo: nil)
        }
        return result
    }

    func _struct<T: Deserializable>(type: T.Type) throws -> T {
        return try T.deserialize(from: self)
    }

    func u8() throws -> UInt8 {
        return UInt8(try readInt(length: 1))
    }

    func u16() throws -> UInt16 {
        return UInt16(try readInt(length: 2))
    }

    func u32() throws -> UInt32 {
        return UInt32(try readInt(length: 4))
    }

    func u64() throws -> UInt64 {
        return UInt64(try readInt(length: 8))
    }

    func u128() throws -> UInt128 {
        return UInt128(try readInt(length: 16))
    }

    func u256() throws -> UInt256 {
        return UInt256(try readInt(length: 32))
    }

    func uleb128() throws -> Int {
        var value: UInt = 0
        var shift: UInt = 0

        while value <= UInt(MAX_U32) {
            let byte = try readInt(length: 1)
            value |= (UInt(byte) & 0x7F) << shift
            if byte & 0x80 == 0 {
                break
            }
            shift += 7
        }

        if value > UInt(MAX_U128) {
            throw NSError(domain: "Unexpectedly large uleb128 value", code: -1, userInfo: nil)
        }

        return Int(value)
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

    private func readInt(length: Int) throws -> UInt {
        let data = try read(length: length)
        return data.withUnsafeBytes { $0.load(as: UInt.self) }
    }
}

protocol Deserializable {
    static func deserialize(from deserializer: Deserializer) throws -> Self
}
