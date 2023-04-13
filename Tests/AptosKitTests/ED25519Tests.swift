//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import XCTest
@testable import AptosKit

final class ED25519Tests: XCTestCase {
    func testThatSigningAndVerifyingWorksAsIntended() throws {
        guard let input: Data = "test_message".data(using: .utf8) else {
            XCTFail("Invalid Input")
            return
        }
        
        let privateKey = try PrivateKey.random()
        let publicKey = try privateKey.publicKey()

        let signature = try privateKey.sign(data: input)
        XCTAssertTrue(try publicKey.verify(data: input, signature: signature))
    }
    
    func testThatPrivateKeySerializationWorksAsIntended() throws {
        let privateKey = try PrivateKey.random()
        let ser = Serializer()
        
        try privateKey.serialize(ser)
        let serPrivateKey = try PrivateKey.deserialize(from: Deserializer(data: ser.output()))
        XCTAssertEqual(privateKey, serPrivateKey)
    }
    
    func testThatPublicKeySerializationWorksAsIntended() throws {
        let privateKey = try PrivateKey.random()
        let publicKey = try privateKey.publicKey()
        
        let ser = Serializer()
        try publicKey.serialize(ser)
        let serPublicKey = try PublicKey.deserialize(from: Deserializer(data: ser.output()))
        XCTAssertEqual(publicKey, serPublicKey)
    }
    
    func testThatSignatureSerializationWorksAsIntended() throws {
        let privateKey = try PrivateKey.random()
        guard let input: Data = "another_message".data(using: .utf8) else {
            XCTFail("Invalid Input")
            return
        }
        let signature = try privateKey.sign(data: input)
        
        let ser = Serializer()
        signature.serialize(ser)
        let serSignature = try Signature.deserialize(from: Deserializer(data: ser.output()))
        
        XCTAssertEqual(signature, serSignature)
    }
}