//
//  SECP256K1Tests.swift
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
@testable import AptosKit

final class SECP256K1Tests: XCTestCase {
    func testThatSigningAndVerifyingWorksAsIntended() throws {
        guard let input: Data = "test_message".data(using: .utf8) else {
            XCTFail("Invalid Input")
            return
        }

        let privateKey = try SECP256K1PrivateKey()
        let publicKey = try privateKey.publicKey()

        let signature = try privateKey.sign(data: input)
        XCTAssertTrue(try publicKey.verify(data: input, signature: signature))
    }

    func testThatPrivateKeySerializationWorksAsIntended() throws {
        let privateKey = try SECP256K1PrivateKey()
        let ser = Serializer()

        try privateKey.serialize(ser)
        let serPrivateKey = try SECP256K1PrivateKey.deserialize(from: Deserializer(data: ser.output()))
        XCTAssertEqual(privateKey, serPrivateKey)
    }

    func testThatPublicKeySerializationWorksAsIntended() throws {
        let privateKey = try SECP256K1PrivateKey()
        let publicKey = try privateKey.publicKey()

        let ser = Serializer()
        try publicKey.serialize(ser)
        let serPublicKey = try SECP256K1PublicKey.deserialize(from: Deserializer(data: ser.output()))
        XCTAssertEqual(publicKey, serPublicKey)
    }

    func testThatSignatureSerializationWorksAsIntended() throws {
        let privateKey = try SECP256K1PrivateKey()
        guard let input: Data = "another_message".data(using: .utf8) else {
            XCTFail("Invalid Input")
            return
        }
        let signature = try privateKey.sign(data: input)

        let ser = Serializer()
        try signature.serialize(ser)
        let serSignature = try Signature.deserialize(from: Deserializer(data: ser.output()))

        XCTAssertEqual(signature, serSignature)
    }
}
