//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/13/23.
//

import XCTest
@testable import AptosKit

final class AccountAddressTests: XCTestCase {
    func testThatFromHexWillCreateTheProperKeysForTheAccount() throws {
        let account = try AccountAddress.fromHex(
            "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d"
        )
        
        XCTAssertEqual(account.hex(), "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d")
    }
    
    func testThatFromKeyWillCreateTheProperKeysForTheAccount() throws {
        let account = try AccountAddress.fromKey(
            PrivateKey.fromHex("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c").publicKey()
        )
        
        XCTAssertEqual(account.hex(), "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d")
    }
    
    func testThatMultiED25519WillCreateTheProperKeysForTheAccount() throws {
        let privateKey1 = PrivateKey.fromHex("4e5e3be60f4bbd5e98d086d932f3ce779ff4b58da99bf9e5241ae1212a29e5fe")
        let privateKey2 = PrivateKey.fromHex("1e70e49b78f976644e2c51754a2f049d3ff041869c669523ba95b172c7329901")
        let multisigPublicKey = try MultiPublicKey(
            keys: [try privateKey1.publicKey(), try privateKey2.publicKey()],
            threshold: 1
        )
        let expectedAccountAddress = try AccountAddress.fromHex("835bb8c5ee481062946b18bbb3b42a40b998d6bf5316ca63834c959dc739acf0")
        let actualAccountAddress = try AccountAddress.fromMultiEd25519(keys: multisigPublicKey)
        XCTAssertEqual(expectedAccountAddress, actualAccountAddress)
    }
    
    func testThatResourceAccountWillCreateTheProperResourcesForTheAccount() throws {
        let baseAddress = try AccountAddress.fromHex("b0b")
        let expected = try AccountAddress.fromHex("ee89f8c763c27f9d942d496c1a0dcf32d5eacfe78416f9486b8db66155b163b0")
        let seed = Data([0x0b, 0x00, 0x0b])
        let actual = try AccountAddress.forResourceAccount(baseAddress, seed: seed)
        XCTAssertEqual(expected, actual)
    }
}

