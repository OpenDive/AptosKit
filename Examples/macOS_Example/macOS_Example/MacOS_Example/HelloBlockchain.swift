//
//  HelloBlockchain.swift
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
import SwiftyJSON
import AptosKit

extension RestClient {
    /// Retrieve the resource message::MessageHolder::message
    func getMessage(
        _ contractAddress: String,
        _ accountAddress: AccountAddress
    ) async throws -> JSON {
        return try await self.accountResource(accountAddress, "0x\(contractAddress)::message::MessageHolder")
    }

    /// Potentially initialize and set the resource message::MessageHolder::message
    func setMessage(
        _ contractAddress: String,
        _ sender: Account,
        _ message: String
    ) async throws -> String {
        let payload = try EntryFunction.natural(
            "0x\(contractAddress)::message",
            "set_message",
            [],
            [AnyTransactionArgument(TransactionArgument(value: message, encoder: Serializer.str))]
        )
        let signedTransaction = try await self.createBcsSignedTransaction(sender, TransactionPayload(payload: payload))
        return try await self.submitBcsTransaction(signedTransaction)
    }
}

struct HelloBlockchain {
    static func helloBlockchainTest() async throws {
        let contractAddress = "INSERT_CONTRACT_ADDRESS_HERE"

        let alice = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        let bob = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))

        print("\n=== Addresses ===")
        print("Alice: \(alice.account.address().description)")
        print("Bob: \(bob.account.address().description)")

        let restClient = try await RestClient(baseUrl: "https://fullnode.devnet.aptoslabs.com/v1")
        let faucetClient = FaucetClient(
            baseUrl: "https://faucet.devnet.aptoslabs.com",
            restClient: restClient
        )

        let _ = try await faucetClient.fundAccount(
            alice.account.address().description,
            20_000
        )
        let _ = try await faucetClient.fundAccount(
            bob.account.address().description,
            20_000
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

        print("\n=== Testing Alice ===")
        print("Initial value: \(try await restClient.getMessage(contractAddress, alice.account.address()))")
        print("Setting the message to \"Hello, Blockchain\"")
        let txnHashSetMessageAlice = try await restClient.setMessage(contractAddress, alice.account, "Hello, Blockchain")
        try await restClient.waitForTransaction(txnHashSetMessageAlice)

        print("New value: \(try await restClient.getMessage(contractAddress, alice.account.address()))")

        print("\n=== Testing Bob ===")
        print("Initial value: \(try await restClient.getMessage(contractAddress, bob.account.address()))")
        print("Setting the message to \"Hello, Blockchain\"")
        let txnHashSetMessageBob = try await restClient.setMessage(contractAddress, bob.account, "Hello, Blockchain")
        try await restClient.waitForTransaction(txnHashSetMessageBob)

        print("New value: \(try await restClient.getMessage(contractAddress, bob.account.address()))")
    }
}
