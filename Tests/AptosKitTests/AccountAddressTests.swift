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
}

