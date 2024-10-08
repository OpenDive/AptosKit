//
//  BCSTests.swift
//  AptosKit
//
//  Copyright (c) 2024 OpenDive
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

import XCTest
import UInt256
@testable import AptosKit

final class BCSTests: XCTestCase {
    func testThatBoolSerializationAndDeserializationWorksWithTrue() throws {
        let input: Bool = true
        let ser = Serializer()
        try Serializer.bool(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try der.bool()

        XCTAssertEqual(input, output)
    }

    func testThatBoolSerializationAndDeserializationWorksWithFalse() throws {
        let input: Bool = false
        let ser = Serializer()
        try Serializer.bool(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try der.bool()

        XCTAssertEqual(input, output)
    }

    func testThatBoolSerializationAndDeserializationThrowAnErrorWithInvalidInput() throws {
        let input: Int = 32
        let ser = Serializer()
        try Serializer.u8(ser, UInt8(input))
        let der = Deserializer(data: ser.output())

        XCTAssertThrowsError(try der.bool())
    }

    func testThatBytesSerializationAndDeserializationWorksWithData() throws {
        guard let input: Data = "1234567890".data(using: .utf8) else {
            XCTFail("String Data is invalid")
            return
        }
        let ser = Serializer()
        try Serializer.toBytes(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.toBytes(der)

        XCTAssertEqual(input, output)
    }

    func testThatMapSerializationAndDeserializationWorksWithMaps() throws {
        let input: [String: UInt32] = [
            "a": 12345,
            "b": 99234,
            "c": 23829
        ]
        let ser = Serializer()
        try ser.map(input, keyEncoder: Serializer.str, valueEncoder: Serializer.u32)
        let der = Deserializer(data: ser.output())
        let output = try der.map(keyDecoder: Deserializer.string, valueDecoder: Deserializer.u32)

        XCTAssertEqual(input, output)
    }

    func testThatSequenceSerializationAndDeserializationWorksWithArrays() throws {
        let input: [String] = ["a", "abc", "def", "ghi"]
        let ser = Serializer()
        try ser.sequence(input, Serializer.str)
        let der = Deserializer(data: ser.output())
        let output = try der.sequence(valueDecoder: Deserializer.string)

        XCTAssertEqual(input, output)
    }

    func testThatSequenceSerializerSerializationAndDeserializationWorksWithArrays() throws {
        let input: [String] = ["a", "abc", "def", "ghi"]
        let ser = Serializer()
        let seqSer: (Serializer, [String]) throws -> Void = Serializer.sequenceSerializer(Serializer.str)
        try seqSer(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try der.sequence(valueDecoder: Deserializer.string)

        XCTAssertEqual(input, output)
    }

    func testThatStringSerializationAndDeserializationWorksWithStrings() throws {
        let input: String = "1234567890"
        let ser = Serializer()
        try Serializer.str(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.string(der)

        XCTAssertEqual(input, output)
    }

    func testThatU8SerializationAndDeserializationWorksWithUInt8s() throws {
        let input: UInt8 = 15
        let ser = Serializer()
        try Serializer.u8(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u8(der)

        XCTAssertEqual(input, output)
    }

    func testThatU16SerializationAndDeserializationWorksWithUInt16s() throws {
        let input: UInt16 = 111_15
        let ser = Serializer()
        try Serializer.u16(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u16(der)

        XCTAssertEqual(input, output)
    }

    func testThatU32SerializationAndDeserializationWorksWithUInt32s() throws {
        let input: UInt32 = 1_111_111_115
        let ser = Serializer()
        try Serializer.u32(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u32(der)

        XCTAssertEqual(input, output)
    }

    func testThatU64SerializationAndDeserializationWorksWithUInt64s() throws {
        let input: UInt64 = 1_111_111_111_111_111_115
        let ser = Serializer()
        try Serializer.u64(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u64(der)

        XCTAssertEqual(input, output)
    }

    func testThatU128SerializationAndDeserializationWorksWithUInt128s() throws {
        let input: UInt128 = UInt128("1111111111111111111111111111111111115")!
        let ser = Serializer()
        try Serializer.u128(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u128(der)

        XCTAssertEqual(input, output)
    }

    func testThatU256SerializationAndDeserializationWorksWithUInt256s() throws {
        let input: UInt256 = UInt256("111111111111111111111111111111111111111111111111111111111111111111111111111115")!
        let ser = Serializer()
        try Serializer.u256(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u256(der)

        XCTAssertEqual(input, output)
    }

    func testThatULeb128SerializationAndDeserializationWorksWithUInts() throws {
        let input: UInt = 1_111_111_115
        let ser = Serializer()
        try ser.uleb128(input)
        let der = Deserializer(data: ser.output())
        let output = try der.uleb128()

        XCTAssertEqual(input, output)
    }

    func testThatStructureSerializationAndDeserializationWorksWithStructures() throws {
        struct MyStruct: KeyProtocol, Equatable {
            let str: String
            let str2: String
            let bool: Bool
            let vector: [UInt8]

            func serialize(_ serializer: Serializer) throws {
                try Serializer.str(serializer, str)
                try Serializer.str(serializer, str2)
                try Serializer.bool(serializer, bool)
                try serializer.sequence(vector, Serializer.u8)
            }

            static func deserialize(from deserializer: Deserializer) throws -> MyStruct {
                return MyStruct(
                    str: try Deserializer.string(deserializer),
                    str2: try Deserializer.string(deserializer),
                    bool: try deserializer.bool(),
                    vector: try deserializer.sequence(valueDecoder: Deserializer.u8)
                )
            }
        }
        let input: MyStruct = MyStruct(str: "Hello", str2: "World", bool: true, vector: [0xC0, 0xDE])
        let ser = Serializer()
        try Serializer._struct(ser, value: input)
        let der = Deserializer(data: ser.output())
        let output: MyStruct = try Deserializer._struct(der)
        XCTAssertEqual(input, output)
    }
}
