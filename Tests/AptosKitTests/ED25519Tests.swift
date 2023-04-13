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
    
    func testThatMultiSignatureWorksAsIntended() throws {
//        let privateKey1 = PrivateKey.fromHex("4e5e3be60f4bbd5e98d086d932f3ce779ff4b58da99bf9e5241ae1212a29e5fe")
//        let privateKey2 = PrivateKey.fromHex("1e70e49b78f976644e2c51754a2f049d3ff041869c669523ba95b172c7329901")
//
//        let publicKey1 = try privateKey1.publicKey()
//        let publicKey2 = try privateKey2.publicKey()
//
//        let multisigPublicKey = try MultiPublicKey(
//            keys: [publicKey1, publicKey2], threshold: 1
//        )
    }
}
