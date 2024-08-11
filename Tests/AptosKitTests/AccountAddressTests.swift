//
//  AccountAddressTests.swift
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

final class AccountAddressTests: XCTestCase {
    func testThatFromHexWillCreateTheProperKeysForTheAccount() throws {
        let account = try AccountAddress.fromStrRelaxed(
            "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d"
        )

        XCTAssertEqual(account.description, "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d")
    }

    func testThatFromKeyWillCreateTheProperKeysForTheAccount() throws {
        let account = try AccountAddress.fromKey(
            ED25519PrivateKey.fromHex("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c").publicKey()
        )

        XCTAssertEqual(account.description, "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d")
    }

    func testThatMultiED25519WillCreateTheProperKeysForTheAccount() throws {
        let privateKey1 = ED25519PrivateKey.fromHex("4e5e3be60f4bbd5e98d086d932f3ce779ff4b58da99bf9e5241ae1212a29e5fe")
        let privateKey2 = ED25519PrivateKey.fromHex("1e70e49b78f976644e2c51754a2f049d3ff041869c669523ba95b172c7329901")
        let multisigPublicKey = try MultiED25519PublicKey(
            keys: [try privateKey1.publicKey(), try privateKey2.publicKey()],
            threshold: 1
        )
        let expectedAccountAddress = try AccountAddress.fromStrRelaxed("835bb8c5ee481062946b18bbb3b42a40b998d6bf5316ca63834c959dc739acf0")
        let actualAccountAddress = try AccountAddress.fromMultiEd25519(keys: multisigPublicKey)
        XCTAssertEqual(expectedAccountAddress, actualAccountAddress)
    }

    func testThatResourceAccountWillCreateTheProperResourcesForTheAccount() throws {
        let baseAddress = try AccountAddress.fromStrRelaxed("b0b")
        let expected = try AccountAddress.fromStrRelaxed("ee89f8c763c27f9d942d496c1a0dcf32d5eacfe78416f9486b8db66155b163b0")
        let seed = Data([0x0b, 0x00, 0x0b])
        let actual = try AccountAddress.forResourceAccount(baseAddress, seed: seed)
        XCTAssertEqual(expected, actual)
    }

    func testThatNamedObjectsWillCreateTheProperNamedObjectForTheAccount() throws {
        let baseAddress = try AccountAddress.fromStrRelaxed("b0b")
        let expected = try AccountAddress.fromStrRelaxed("f417184602a828a3819edf5e36285ebef5e4db1ba36270be580d6fd2d7bcc321")
        guard let seed = "bob's collection".data(using: .utf8) else {
            XCTFail("Invalid data")
            return
        }
        let actual = try AccountAddress.forNamedObject(baseAddress, seed: seed)
        XCTAssertEqual(expected, actual)
    }

    func testThatCollectionsWillCreateTheProperNamedCollectionForTheAccount() throws {
        let baseAddress = try AccountAddress.fromStrRelaxed("b0b")
        let expected = try AccountAddress.fromStrRelaxed("f417184602a828a3819edf5e36285ebef5e4db1ba36270be580d6fd2d7bcc321")
        let actual = try AccountAddress.forNamedCollection(baseAddress, "bob's collection")
        XCTAssertEqual(expected, actual)
    }

    func testThatNamedTokensWillCreateTheProperNamedTokenForTheAccount() throws {
        let baseAddress = try AccountAddress.fromStrRelaxed("b0b")
        let expected = try AccountAddress.fromStrRelaxed("e20d1f22a5400ba7be0f515b7cbd00edc42dbcc31acc01e31128b2b5ddb3c56e")
        let actual = try AccountAddress.forNamedToken(baseAddress, "bob's collection", "bob's token")
        XCTAssertEqual(expected, actual)
    }

    func testThatAccountAddressSerializationAndDeserializationWorksAsIntended() throws {
        let baseAddress = try AccountAddress.fromStrRelaxed("b0b")
        let ser = Serializer()
        try baseAddress.serialize(ser)
        let der = Deserializer(data: ser.output())
        let output = try AccountAddress.deserialize(from: der)
        
        XCTAssertEqual(baseAddress, output)
    }

    func testThatStandardStringsInitializeAsIntended() throws {
        // Test special address: 0x0
        XCTAssertEqual(try AccountAddress.fromStr("0x0000000000000000000000000000000000000000000000000000000000000000").description, "0x0")

        // Test special address: 0x1
        XCTAssertEqual(try AccountAddress.fromStr("0x0000000000000000000000000000000000000000000000000000000000000001").description, "0x1")

        // Test special address: 0x4
        XCTAssertEqual(try AccountAddress.fromStr("0x0000000000000000000000000000000000000000000000000000000000000004").description, "0x4")

        // Test special address: 0xf
        XCTAssertEqual(try AccountAddress.fromStr("0x000000000000000000000000000000000000000000000000000000000000000f").description, "0xf")

        // Test special address from short no 0x: d
        XCTAssertEqual(try AccountAddress.fromStrRelaxed("d").description, "0xd")

        // Test non-special address from long:
        // 0x0000000000000000000000000000000000000000000000000000000000000010
        var value = "0x0000000000000000000000000000000000000000000000000000000000000010"
        XCTAssertEqual(try AccountAddress.fromStr(value).description, value)

        // Test non-special address from long:
        // 0x000000000000000000000000000000000000000000000000000000000000001f
        value = "0x000000000000000000000000000000000000000000000000000000000000001f"
        XCTAssertEqual(try AccountAddress.fromStr(value).description, value)

        // Test non-special address from long:
        // 0x00000000000000000000000000000000000000000000000000000000000000a0
        value = "0x00000000000000000000000000000000000000000000000000000000000000a0"
        XCTAssertEqual(try AccountAddress.fromStr(value).description, value)

        // Test non-special address from long no 0x:
        // ca843279e3427144cead5e4d5999a3d0ca843279e3427144cead5e4d5999a3d0
        value = "ca843279e3427144cead5e4d5999a3d0ca843279e3427144cead5e4d5999a3d0"
        XCTAssertEqual(try AccountAddress.fromStrRelaxed(value).description, "0x\(value)")

        // Test non-special address from long no 0x:
        // 1000000000000000000000000000000000000000000000000000000000000000
        value = "1000000000000000000000000000000000000000000000000000000000000000"
        XCTAssertEqual(try AccountAddress.fromStrRelaxed(value).description, "0x\(value)")

        // Demonstrate that neither leading nor trailing zeroes get trimmed for
        // non-special addresses:
        // 0f00000000000000000000000000000000000000000000000000000000000000
        value = "0f00000000000000000000000000000000000000000000000000000000000000"
        XCTAssertEqual(try AccountAddress.fromStrRelaxed(value).description, "0x\(value)")
    }
}
