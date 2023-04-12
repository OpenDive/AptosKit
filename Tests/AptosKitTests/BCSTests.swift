//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import XCTest
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
}
