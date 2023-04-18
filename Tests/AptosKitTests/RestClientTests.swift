//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/13/23.
//

import XCTest
@testable import AptosKit

final class RestClientTests: XCTestCase {
    func testThatAccountWillReturnTheCorrectInformationAboutAnAccount() async throws {
        let mockRestClient = MockRestClient()
        let account = try Account.loadKey("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c")
        let result = try await mockRestClient.account(account.accountAddress)
        
        XCTAssertEqual(result.sequenceNumber, "1")
        XCTAssertEqual(result.authenticationKey, "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d")
    }
    
    func testThatAccountResourcesWillReturnTheCorrectInformationAboutAccountResources() async throws {
        let mockRestClient = MockRestClient()
        let account = try Account.loadKey("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c")
        let result = try await mockRestClient.accountResource(account.accountAddress, "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>")
        
        XCTAssertEqual(result["data"]["coin"]["value"].intValue, 647362)
    }
    
    func testThatAccountBalanceWillReturnTheCorrectInformationAboutAccountBalance() async throws {
        let mockRestClient = MockRestClient()
        let account = try Account.loadKey("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c")
        let result = try await mockRestClient.accountBalance(account.accountAddress)
        
        XCTAssertEqual(result, 647362)
    }
    
    func testThatAccountSequenceNumberWillReturnTheCorrectSequenceNumber() async throws {
        let mockRestClient = MockRestClient()
        let account = try Account.loadKey("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c")
        let result = try await mockRestClient.accountSequenceNumber(account.accountAddress)
        
        XCTAssertEqual(result, 1)
    }
    
    func testThatTableItemsWillReturnTheCorrectValues() async throws {
        let mockRestClient = MockRestClient()
        let account = try Account.loadKey("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c")
        let result = try await mockRestClient.getTableItem(
            "0x1b854694ae746cdbd8d44186ca4929b2b337df21d1c74633be19b2710552fdca",
            "address",
            "u128",
            "0x619dc29a0aac8fa146714058e8dd6d2d0f3bdf5f6331907bf91f3acd81e6935"
        )
        
        XCTAssertEqual(result.intValue, 102994413849650711)
    }
}
