//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/13/23.
//

import XCTest
@testable import AptosKit

final class RestClientTests: XCTestCase {
    let baseUrl: String = "https://fullnode.mainnet.aptoslabs.com/v1"
    
    func testThatAccountWillReturnTheCorrectInformationAboutAnAccount() async throws {
        let restClient = RestClient(baseUrl: baseUrl)
        let account = try Account.loadKey("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c")
        let result = try await restClient.account(account.accountAddress)
        
        XCTAssertEqual(result.sequenceNumber, "1")
        XCTAssertEqual(result.authenticationKey, "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d")
    }
    
    func testThatAccountResourcesWillReturnTheCorrectInformationAboutAccountResources() async throws {
        let restClient = RestClient(baseUrl: baseUrl)
        let account = try Account.loadKey("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c")
        let result = try await restClient.accountResource(account.accountAddress, "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>")
        XCTAssertEqual(result["data"]["coin"]["value"].intValue, 749262)
    }
    
    func testThatAccountBalanceWillReturnTheCorrectInformationAboutAccountBalance() async throws {
        let restClient = RestClient(baseUrl: baseUrl)
        let account = try Account.loadKey("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c")
        let result = try await restClient.accountBalance(account.accountAddress)
        XCTAssertEqual(result, 749262)
    }
}
