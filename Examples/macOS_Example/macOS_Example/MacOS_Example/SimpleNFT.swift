//
//  SimpleNFT.swift
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

import Foundation
import AptosKit

struct SimpleNFT {
    static func simpleNftTest() async throws {
        // MARK: Section 1
        let restClient = try await RestClient(baseUrl: "https://fullnode.devnet.aptoslabs.com/v1")
        let faucetClient = FaucetClient(
            baseUrl: "https://faucet.devnet.aptoslabs.com",
            restClient: restClient
        )
        
        // MARK: Section 2
        let alice = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        let bob = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        
        let collectionName = "Alice's"
        let tokenName = "Alice's first token"
        let propertyVersion = 0
        
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
            100_000_000
        )
        
        print("\n=== Initial Coin Balances ===")
        let aliceBalance = try await restClient.accountBalance(
            alice.account.address()
        )
        let bobBalance = try await restClient.accountBalance(
            bob.account.address()
        )
        print("Alice: \(aliceBalance)")
        print("Bob: \(bobBalance)")
        
        print("\n=== Creating Collection and Token ===")
        
        // MARK: Section 4
        let txnHashCreateCollection = try await restClient.createCollection(
            alice.account,
            collectionName,
            "Alice's simple collection",
            "https://aptos.dev"
        )
        try await restClient.waitForTransaction(txnHashCreateCollection)
        
        // MARK: Section 5
        let txnHashCreateToken = try await restClient.createToken(
            alice.account,
            collectionName,
            tokenName,
            "Alice's simple token",
            1,
            "https://aptos.dev/img/nyan.jpeg",
            0
        )
        try await restClient.waitForTransaction(txnHashCreateToken)
        
        // MARK: Section 6
        let collectionData = try await restClient.getCollection(alice.account.address(), collectionName)
        print("Alice's collection: \(collectionData)")
        
        // MARK: Section 7
        let balance = try await restClient.getTokenBalance(
            alice.account.address(),
            alice.account.address(),
            collectionName,
            tokenName,
            propertyVersion
        )
        print("Alice's token balance: \(balance)")
        
        // MARK: Section 8
        let tokenData = try await restClient.getTokenData(
            alice.account.address(),
            collectionName,
            tokenName,
            propertyVersion
        )
        print("Alice's Token Data: \(tokenData)")
        
        print("\n=== Transferring the token to Bob ===")
        
        // MARK: Section 9
        let txnHashOfferToken = try await restClient.offerToken(
            alice.account,
            bob.account.address(),
            alice.account.address(),
            collectionName,
            tokenName,
            propertyVersion, 1
        )
        try await restClient.waitForTransaction(txnHashOfferToken)
        
        // MARK: Section 10
        let txnHashClaimToken = try await restClient.claimToken(
            bob.account,
            alice.account.address(),
            alice.account.address(),
            collectionName,
            tokenName,
            propertyVersion
        )
        try await restClient.waitForTransaction(txnHashClaimToken)
        
        let aliceTokenBalance = try await restClient.getTokenBalance(
            alice.account.address(),
            alice.account.address(),
            collectionName,
            tokenName,
            propertyVersion
        )
        let bobTokenBalance = try await restClient.getTokenBalance(
            bob.account.address(),
            alice.account.address(),
            collectionName,
            tokenName,
            propertyVersion
        )
        
        print("Alice's Token Balance: \(aliceTokenBalance)")
        print("Bob's Token Balance: \(bobTokenBalance)")
        
        print("\n=== Transferring the token back to Alice using MultiAgent ===")
        
        // MARK: Section 11
        let txnHashDirectTransferToken = try await restClient.directTransferToken(
            bob.account,
            alice.account,
            alice.account.address(),
            collectionName,
            tokenName,
            propertyVersion,
            1
        )
        try await restClient.waitForTransaction(txnHashDirectTransferToken)

        let aliceDirectTransferTokenBalance = try await restClient.getTokenBalance(
            alice.account.address(),
            alice.account.address(),
            collectionName,
            tokenName,
            propertyVersion
        )
        let bobDirectTransferTokenBalance = try await restClient.getTokenBalance(
            bob.account.address(),
            alice.account.address(),
            collectionName,
            tokenName,
            propertyVersion
        )
        
        print("Alice's Direct Transfer Token Balance: \(aliceDirectTransferTokenBalance)")
        print("Bob's Direct Transfer Token Balance: \(bobDirectTransferTokenBalance)")
    }
}
