//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import XCTest
import UInt256
@testable import AptosKit

final class BCSTests: XCTestCase {
    func testThatBoolSerializationAndDeserializationWorksWithTrue() throws {
        let input: Bool = true
        let ser = Serializer()
        ser.bool(input)
        let der = Deserializer(data: ser.output())
        let output = try der.bool()
        
        XCTAssertEqual(input, output)
    }
    
    func testThatBoolSerializationAndDeserializationWorksWithFalse() throws {
        let input: Bool = false
        let ser = Serializer()
        ser.bool(input)
        let der = Deserializer(data: ser.output())
        let output = try der.bool()
        
        XCTAssertEqual(input, output)
    }
    
    func testThatBoolSerializationAndDeserializationThrowAnErrorWithInvalidInput() throws {
        let input: Int = 32
        let ser = Serializer()
        Serializer.u8(ser, UInt8(input))
        let der = Deserializer(data: ser.output())
        
        XCTAssertThrowsError(try der.bool())
    }
    
    func testThatBytesSerializationAndDeserializationWorksWithData() throws {
        guard let input: Data = "1234567890".data(using: .utf8) else {
            XCTFail("String Data is invalid")
            return
        }
        let ser = Serializer()
        Serializer.toBytes(ser, input)
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
        ser.map(input, keyEncoder: Serializer.str, valueEncoder: Serializer.u32)
        let der = Deserializer(data: ser.output())
        let output = try der.map(keyDecoder: Deserializer.string, valueDecoder: Deserializer.u32)
        
        XCTAssertEqual(input, output)
    }
    
    func testThatSequenceSerializationAndDeserializationWorksWithArrays() throws {
        let input: [String] = ["a", "abc", "def", "ghi"]
        let ser = Serializer()
        ser.sequence(input, Serializer.str)
        let der = Deserializer(data: ser.output())
        let output = try der.sequence(valueDecoder: Deserializer.string)
        
        XCTAssertEqual(input, output)
    }
    
    func testThatSequenceSerializerSerializationAndDeserializationWorksWithArrays() throws {
        let input: [String] = ["a", "abc", "def", "ghi"]
        let ser = Serializer()
        let seqSer = Serializer.sequenceSerializer(Serializer.str)
        seqSer(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try der.sequence(valueDecoder: Deserializer.string)
        
        XCTAssertEqual(input, output)
    }
    
    func testThatStringSerializationAndDeserializationWorksWithStrings() throws {
        let input: String = "1234567890"
        let ser = Serializer()
        Serializer.str(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.string(der)
        
        XCTAssertEqual(input, output)
    }
    
    func testThatU8SerializationAndDeserializationWorksWithUInt8s() throws {
        let input: UInt8 = 15
        let ser = Serializer()
        Serializer.u8(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u8(der)
        
        XCTAssertEqual(input, output)
    }
    
    func testThatU16SerializationAndDeserializationWorksWithUInt16s() throws {
        let input: UInt16 = 111_15
        let ser = Serializer()
        Serializer.u16(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u16(der)
        
        XCTAssertEqual(input, output)
    }
    
    func testThatU32SerializationAndDeserializationWorksWithUInt32s() throws {
        let input: UInt32 = 1_111_111_115
        let ser = Serializer()
        Serializer.u32(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u32(der)
        
        XCTAssertEqual(input, output)
    }
    
    func testThatU64SerializationAndDeserializationWorksWithUInt64s() throws {
        let input: UInt64 = 1_111_111_111_111_111_115
        let ser = Serializer()
        Serializer.u64(ser, input)
        let der = Deserializer(data: ser.output())
        let output = try Deserializer.u64(der)
        
        XCTAssertEqual(input, output)
    }
}
