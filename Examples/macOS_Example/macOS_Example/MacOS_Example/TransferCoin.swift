//
//  TransferCoin.swift
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

import Foundation
import AptosKit

struct TransferCoin {
    static func transferCoinTest() async throws {
        // MARK: Section 1
        let restClient = try await RestClient(baseUrl: "https://fullnode.devnet.aptoslabs.com/v1")
        let faucetClient = FaucetClient(
            baseUrl: "https://faucet.devnet.aptoslabs.com",
            restClient: restClient
        )
        
        // MARK: Section 2
        let alice = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        let bob = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        
        print("\n=== Addresses ===")
        print("Alice: \(alice.account.address().description)")
        print("Bob: \(bob.account.address().description)")

        // MARK: Section 3
        let _ = try await faucetClient.fundAccount(
            alice.account.address().description,
            100_000_000
        )
        let _ = try await faucetClient.fundAccount(
            bob.account.address().description,
            0
        )

        // MARK: Section 4
        print("\n=== Initial Coin Balances ===")
        var aliceBalance = try await restClient.accountBalance(
            alice.account.address()
        )
        var bobBalance = try await restClient.accountBalance(
            bob.account.address()
        )
        print("Alice: \(aliceBalance)")
        print("Bob: \(bobBalance)")
        
        // Have Alice give Bob 1,000 coins
        // MARK: Section 5
        let txnHashTransfer = try await restClient.transfer(
            alice.account,
            bob.account.address(),
            1_000
        )
        
        // MARK: Section 6
        try await restClient.waitForTransaction(txnHashTransfer)
        
        print("\n=== Intermediate Balances ===")
        aliceBalance = try await restClient.accountBalance(
            alice.account.address()
        )
        bobBalance = try await restClient.accountBalance(
            bob.account.address()
        )
        print("Alice: \(aliceBalance)")
        print("Bob: \(bobBalance)")
        
        // Have Alice give Bob another 1,000 coins using BCS
        let txnHashBcsTransfer = try await restClient.bcsTransfer(
            alice.account,
            bob.account.address(),
            1_000
        )
        try await restClient.waitForTransaction(txnHashBcsTransfer)
        
        print("\n=== Final Balances ===")
        aliceBalance = try await restClient.accountBalance(
            alice.account.address()
        )
        bobBalance = try await restClient.accountBalance(
            bob.account.address()
        )
        print("Alice: \(aliceBalance)")
        print("Bob: \(bobBalance)")
    }
}
