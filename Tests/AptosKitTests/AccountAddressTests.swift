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
}

