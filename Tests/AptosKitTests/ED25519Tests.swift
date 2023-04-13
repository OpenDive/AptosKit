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
        let privateKey1 = PrivateKey.fromHex("4e5e3be60f4bbd5e98d086d932f3ce779ff4b58da99bf9e5241ae1212a29e5fe")
        let privateKey2 = PrivateKey.fromHex("1e70e49b78f976644e2c51754a2f049d3ff041869c669523ba95b172c7329901")

        let publicKey1 = try privateKey1.publicKey()
        let publicKey2 = try privateKey2.publicKey()

        var multisigPublicKey = try MultiPublicKey(
            keys: [publicKey1, publicKey2], threshold: 1
        )
        
        var ser = Serializer()
        multisigPublicKey.serialize(ser)
        var publicKeyBcs = ser.output().hexEncodedString()
        let expectedPublicKeyBcs: String =
            "41754bb6a4720a658bdd5f532995955db0971ad3519acbde2f1149c3857348006c1634cd4607073f2be4a6f2aadc2b866ddb117398a675f2096ed906b20e0bf2c901"
        XCTAssertEqual(publicKeyBcs, expectedPublicKeyBcs)
        
        let publicKeyBytes = multisigPublicKey.toBytes()
        multisigPublicKey = try MultiPublicKey.fromBytes(publicKeyBytes)
        ser = Serializer()
        multisigPublicKey.serialize(ser)
        publicKeyBcs = ser.output().hexEncodedString()
        XCTAssertEqual(publicKeyBcs, expectedPublicKeyBcs)
        
        guard let encodedMessage = "multisig".data(using: .utf8) else {
            XCTFail("Data type is invalid")
            return
        }
        let signature = try privateKey2.sign(data: encodedMessage)
        let multisigSignature = MultiSignature(
            publicKey: multisigPublicKey,
            signatureMap: [(try privateKey2.publicKey(), signature)]
        )
        ser = Serializer()
        multisigSignature.serialize(ser)
        let multisigSignatureBcs = ser.output().hexEncodedString()
        let expectedMultisigSignatureBcs: String =
                "4402e90d8f300d79963cb7159ffa6f620f5bba4af5d32a7176bfb5480b43897cf4886bbb4042182f4647c9b04f02dbf989966f0facceec52d22bdcc7ce631bfc0c40000000"
        XCTAssertEqual(multisigSignatureBcs, expectedMultisigSignatureBcs)
    }
    
    func testThatMultisigRangeFunctionsAsIntended() throws {
        let keys: [PublicKey] = try (0..<MultiPublicKey.maxKeys + 1).map { _ in try PrivateKey.random().publicKey() }
        
        do {
            _ = try MultiPublicKey(keys: [keys[0]], threshold: 1)
            XCTFail("Key index is out of range.")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Must have between 2 and 32 keys.")
        } catch {
            XCTFail("Error is not NSError type.")
        }
        
        do {
            _ = try MultiPublicKey(keys: keys, threshold: 1)
            XCTFail("Key index is out of range.")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Must have between 2 and 32 keys.")
        } catch {
            XCTFail("Error is not NSError type.")
        }
        
        do {
            _ = try MultiPublicKey(keys: [PublicKey](keys[0..<4]), threshold: 0)
            XCTFail("Key threshold is out of range.")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Threshold must be between 1 and 4.")
        } catch {
            XCTFail("Error is not NSError type.")
        }
        
        do {
            _ = try MultiPublicKey(keys: [PublicKey](keys[0..<4]), threshold: 5)
            XCTFail("Key threshold is out of range.")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Threshold must be between 1 and 4.")
        } catch {
            XCTFail("Error is not NSError type.")
        }
        
        do {
            let error = try MultiPublicKey(keys: [keys[0]], threshold: 1, checked: false)
            _ = try MultiPublicKey.fromBytes(error.toBytes())
            XCTFail("Key index is out of range.")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Must have between 2 and 32 keys.")
        } catch {
            XCTFail("Error is not NSError type.")
        }
        
        do {
            let error = try MultiPublicKey(keys: keys, threshold: 1, checked: false)
            _ = try MultiPublicKey.fromBytes(error.toBytes())
            XCTFail("Key index is out of range.")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Must have between 2 and 32 keys.")
        } catch {
            XCTFail("Error is not NSError type.")
        }
        
        do {
            let error = try MultiPublicKey(keys: [PublicKey](keys[0..<4]), threshold: 0, checked: false)
            _ = try MultiPublicKey.fromBytes(error.toBytes())
            XCTFail("Key threshold is out of range.")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Threshold must be between 1 and 4.")
        } catch {
            XCTFail("Error is not NSError type.")
        }
        
        do {
            let error = try MultiPublicKey(keys: [PublicKey](keys[0..<4]), threshold: 5, checked: false)
            _ = try MultiPublicKey.fromBytes(error.toBytes())
            XCTFail("Key threshold is out of range.")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Threshold must be between 1 and 4.")
        } catch {
            XCTFail("Error is not NSError type.")
        }
    }
}

