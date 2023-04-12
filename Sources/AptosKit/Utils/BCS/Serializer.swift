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

    static func toBytes(_ serializer: Serializer, _ value: Data) {
        serializer.uleb128(UInt(value.count))
        serializer._output.append(value)
    }

    func fixedBytes(_ value: Data) {
        self._output.append(value)
    }
    
    public static func _struct(_ serializer: Serializer, value: Any & KeyProtocol) throws {
        try value.serialize(serializer)
    }

    func map<T, U>(
        _ values: [T: U],
        keyEncoder: (Serializer, T) -> (),
        valueEncoder: (Serializer, U) -> ()
    ) {
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

        self.uleb128(UInt(encodedValues.count))
        for (key, value) in encodedValues {
            self.fixedBytes(key)
            self.fixedBytes(value)
        }
    }

    static func sequenceSerializer<T>(
        _ valueEncoder: @escaping (Serializer, T) -> ()
    ) -> (Serializer, [T]) -> Void {
        return { (self, values) in self.sequence(values, valueEncoder) }
    }

    func sequence<T>(
        _ values: [T],
        _ valueEncoder: (Serializer, T) throws -> ()
    ) {
        self.uleb128(UInt(values.count))
        for value in values {
            do {
                let bytes = try encoder(value, valueEncoder)
                self.fixedBytes(bytes)
            } catch {
                continue
            }
        }
    }

    public static func str(_ serializer: Serializer, _ value: String) {
        Serializer.toBytes(serializer, value.data(using: .utf8)!)
    }

    public static func u8(_ serializer: Serializer, _ value: UInt8) {
        serializer.writeInt(value, length: 1)
    }

    public static func u16(_ serializer: Serializer, _ value: UInt16) {
        serializer.writeInt(value, length: 2)
    }

    public static func u32(_ serializer: Serializer, _ value: UInt32) {
        serializer.writeInt(value, length: 4)
    }

    public static func u64(_ serializer: Serializer, _ value: UInt64) {
        serializer.writeInt(value, length: 8)
    }

    public static func u128(_ serializer: Serializer, _ value: UInt128) {
        serializer.writeInt(value, length: 16)
    }

    public static func u256(_ serializer: Serializer, _ value: UInt256) {
        serializer.writeInt(value, length: 32)
    }

    func uleb128(_ value: UInt) {
        var _value = value
        while _value >= 0x80 {
            let byte = _value & 0x7F
            Serializer.u8(self, UInt8(byte | 0x80))
            _value >>= 7
        }
        Serializer.u8(self, UInt8(_value & 0x7F))
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
