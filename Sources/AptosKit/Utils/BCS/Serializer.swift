//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import Foundation
import UInt256

public class Serializer {
    private var _output: Data

    init() {
        self._output = Data()
    }

    func output() -> Data {
        return self._output
    }

    func bool(_ value: Bool) {
        let result: UInt8 = value ? UInt8(1) : UInt8(0)
        self.writeInt(result, length: 1)
    }

    static func toBytes(_ serializer: Serializer, _ value: Data) throws {
        try serializer.uleb128(UInt(value.count))
        serializer._output.append(value)
    }

    func fixedBytes(_ value: Data) {
        self._output.append(value)
    }
    
    public static func _struct(_ serializer: Serializer, value: EncodingProtocol) throws {
        if let keyProtocolValue = value as? KeyProtocol {
            try keyProtocolValue.serialize(serializer)
        } else {
            throw NSError(domain: "This function does not conform to KeyProtocol", code: -1)
        }
    }

    func map<T, U>(
        _ values: [T: U],
        keyEncoder: (Serializer, T) throws -> (),
        valueEncoder: (Serializer, U) throws -> ()
    ) throws {
        var encodedValues: [(Data, Data)] = []
        for (key, value) in values {
            do {
                let key = try encoder(key, keyEncoder)
                let value = try encoder(value, valueEncoder)
                encodedValues.append((key, value))
            } catch {
                continue
            }
        }
        encodedValues.sort(by: { $0.0 < $1.0 })

        try self.uleb128(UInt(encodedValues.count))
        for (key, value) in encodedValues {
            self.fixedBytes(key)
            self.fixedBytes(value)
        }
    }

    static func sequenceSerializer<T>(
        _ valueEncoder: @escaping (Serializer, T) throws -> ()
    ) -> (Serializer, [T]) throws -> Void {
        return { (self, values) in try self.sequence(values, valueEncoder) }
    }

    func sequence<T>(
        _ values: [T],
        _ valueEncoder: (Serializer, T) throws -> ()
    ) throws {
        try self.uleb128(UInt(values.count))
        for value in values {
            do {
                let bytes = try encoder(value, valueEncoder)
                self.fixedBytes(bytes)
            } catch {
                continue
            }
        }
    }

    public static func str(_ serializer: Serializer, _ value: any EncodingProtocol) throws {
        if let str = value as? String {
            try Serializer.toBytes(serializer, String(str).data(using: .utf8)!)
        } else {
            throw NSError(domain: "Value is not String.", code: -1)
        }
    }

    public static func u8(_ serializer: Serializer, _ value: any EncodingProtocol) throws {
        if let uint8 = value as? UInt8 {
            serializer.writeInt(UInt8(uint8), length: 1)
        } else {
            throw NSError(domain: "Value is not UInt8.", code: -1)
        }
    }

    public static func u16(_ serializer: Serializer, _ value: any EncodingProtocol) throws {
        if let uint16 = value as? UInt16 {
            serializer.writeInt(UInt16(uint16), length: 2)
        } else {
            throw NSError(domain: "Value is not UInt16.", code: -1)
        }
    }

    public static func u32(_ serializer: Serializer, _ value: any EncodingProtocol) throws {
        if let uint32 = value as? UInt32 {
            serializer.writeInt(UInt32(uint32), length: 4)
        } else {
            throw NSError(domain: "Value is not UInt32.", code: -1)
        }
    }

    public static func u64(_ serializer: Serializer, _ value: any EncodingProtocol) throws {
        if let uint64 = value as? UInt64 {
            serializer.writeInt(UInt64(uint64), length: 8)
        } else {
            throw NSError(domain: "Value is not UInt64.", code: -1)
        }
    }

    public static func u128(_ serializer: Serializer, _ value: any EncodingProtocol) throws {
        if let uint128 = value as? UInt128 {
            serializer.writeInt(UInt128(uint128), length: 16)
        } else {
            throw NSError(domain: "Value is not UInt128.", code: -1)
        }
    }

    public static func u256(_ serializer: Serializer, _ value: any EncodingProtocol) throws {
        if let uint256 = value as? UInt256 {
            serializer.writeInt(uint256, length: 32)
        } else {
            throw NSError(domain: "Value is not UInt256.", code: -1)
        }
    }

    func uleb128(_ value: UInt) throws {
        var _value = value
        while _value >= 0x80 {
            let byte = _value & 0x7F
            try Serializer.u8(self, UInt8(byte | 0x80))
            _value >>= 7
        }
        try Serializer.u8(self, UInt8(_value & 0x7F))
    }

    private func writeInt(_ value: any UnsignedInteger, length: Int) {
        var _value = value
        let valueData = withUnsafeBytes(of: &_value) { Data($0) }
        self._output.append(valueData.prefix(length))
    }
}

func encoder<T>(
    _ value: T,
    _ encoder: (Serializer, T) throws -> ()
) throws -> Data {
    let ser = Serializer()
    try encoder(ser, value)
    return ser.output()
}

func < (lhs: Data, rhs: Data) -> Bool {
    let lhsString = lhs.reduce("", { $0 + String(format: "%02x", $1) })
    let rhsString = rhs.reduce("", { $0 + String(format: "%02x", $1) })
    return lhsString < rhsString
}
