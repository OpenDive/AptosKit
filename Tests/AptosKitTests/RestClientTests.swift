//
//  RestClientTests.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
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
        let result = try await mockRestClient.getTableItem(
            "0x1b854694ae746cdbd8d44186ca4929b2b337df21d1c74633be19b2710552fdca",
            "address",
            "u128",
            "0x619dc29a0aac8fa146714058e8dd6d2d0f3bdf5f6331907bf91f3acd81e6935"
        )
        
        XCTAssertEqual(result.intValue, 102994413849650711)
    }

    func testThatAggregatorValueWillReturnTheCorrectValues() async throws {
        let mockRestClient = MockRestClient()
        let account = try Account.loadKey("64f57603b58af16907c18a866123286e1cbce89790613558dc1775abb3fc5c8c")
        let result = try await mockRestClient.aggregatorValue(account.accountAddress, "0x1::coin::CoinInfo<0x1::aptos_coin::AptosCoin>", ["supply"])
        
        XCTAssertEqual(result, 102994413849650711)
    }

    func testThatInfoResponseReturnsTheCorrectValues() async throws {
        let mockRestClient = MockRestClient()
        let result = try await mockRestClient.info()
        
        XCTAssertEqual(result.chainId, 1)
        XCTAssertEqual(result.epoch, "2253")
        XCTAssertEqual(result.ledgerVersion, "124050613")
        XCTAssertEqual(result.oldestLedgerVersion, "0")
        XCTAssertEqual(result.ledgerTimestamp, "1681793118965892")
        XCTAssertEqual(result.nodeRole, "full_node")
        XCTAssertEqual(result.oldestBlockHeight, "0")
        XCTAssertEqual(result.blockHeight, "48194648")
        XCTAssertEqual(result.gitHash, "e80219926372ccd1c69654d7b6bb4ba21a0c9862")
    }

    func testThatEndToEndSimulateTransacrtionWorksAsIntended() async throws {
        let baseUrl = "https://fullnode.devnet.aptoslabs.com/v1"
        let faucetUrl = "https://faucet.devnet.aptoslabs.com"
        
        let restClient = try await RestClient(baseUrl: baseUrl)
        let faucetClient = FaucetClient(baseUrl: faucetUrl, restClient: restClient)
        
        let alice = try Account.generate()
        let bob = try Account.generate()
        
        try await faucetClient.fundAccount(alice.address().description, 100_000_000)
        
        let payload = try EntryFunction.natural(
            "0x1::coin",
            "transfer",
            [TypeTag(value: StructTag.fromStr("0x1::aptos_coin::AptosCoin"))],
            [
                AnyTransactionArgument(TransactionArgument(value: bob.address(), encoder: Serializer._struct)),
                AnyTransactionArgument(TransactionArgument(value: UInt64(100_000), encoder: Serializer.u64))
            ]
        )
        let transaction = try await restClient.createBcsTransaction(
            alice,
            try TransactionPayload(payload: payload)
        )

        let outputFail = try await restClient.simulateTransaction(transaction, alice)
        XCTAssertNotEqual(outputFail[0]["vm_status"].stringValue, "Executed successfully")

        try await faucetClient.fundAccount(bob.address().description, 0)
        let outputSuccess = try await restClient.simulateTransaction(transaction, alice)
        XCTAssertEqual(outputSuccess[0]["vm_status"].stringValue, "Executed successfully")
    }

    func testThatEndToEndTransactionWorksAsIntended() async throws {
        let baseUrl = "https://fullnode.devnet.aptoslabs.com/v1"
        let faucetUrl = "https://faucet.devnet.aptoslabs.com"
        
        let restClient = try await RestClient(baseUrl: baseUrl)
        let faucetClient = FaucetClient(baseUrl: faucetUrl, restClient: restClient)
        
        let alice = try Account.generate()
        let bob = try Account.generate()
        
        try await faucetClient.fundAccount(alice.address().description, 100_000_000)
        try await faucetClient.fundAccount(bob.address().description, 0)
        
        let txnHash = try await restClient.transfer(alice, bob.address(), 1_000)
        try await restClient.waitForTransaction(txnHash)
        let bobsBalance = try await restClient.accountBalance(bob.address())
        
        XCTAssertEqual(bobsBalance, 1_000)
    }   
}
