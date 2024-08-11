//
//  SimulateTransferCoin.swift
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
import SwiftyJSON

struct SimulateTransferCoin {
    static func simulateTransferCoinTest() async throws {
        let restClient = try await RestClient(baseUrl: "https://fullnode.devnet.aptoslabs.com/v1")
        let faucetClient = FaucetClient(
            baseUrl: "https://faucet.devnet.aptoslabs.com",
            restClient: restClient
        )

        let alice = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        let bob = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))

        print("\n=== Addresses ===")
        print("Alice: \(alice.account.address().description)")
        print("Bob: \(bob.account.address().description)")

        let _ = try await faucetClient.fundAccount(
            alice.account.address().description,
            100_000_000
        )

        let payload = try EntryFunction.natural(
            "0x1::coin",
            "transfer",
            [TypeTag(value: try StructTag.fromStr("0x1::aptos_coin::AptosCoin"))],
            [
                AnyTransactionArgument(
                    TransactionArgument(
                        value: bob.account.address(),
                        encoder: Serializer._struct
                    )
                ),
                AnyTransactionArgument(
                    TransactionArgument(
                        value: UInt64(100_000),
                        encoder: Serializer.u64
                    )
                )
            ]
        )

        let transaction = try await restClient.createBcsTransaction(
            alice.account,
            TransactionPayload(payload: payload)
        )

        print("\n=== Simulate before creatng Bob's Account ===")
        let outputBefore = try await restClient.simulateTransaction(transaction, alice.account)
        if outputBefore[0]["success"].boolValue { throw NSError(domain: "Transaction should have failed", code: -1) }
        print("Output before Bob's account creation: \(outputBefore)")

        print("\n=== Simulate after creatng Bob's Account ===")
        let _ = try await faucetClient.fundAccount(
            bob.account.address().description,
            0
        )
        let outputAfter = try await restClient.simulateTransaction(transaction, alice.account)
        if outputAfter[0]["success"].boolValue {
            print("Transaction Executed Successfully!")
            print("Output after Bob's account creation: \(outputAfter)")
        }
        else {
            throw NSError(domain: "Transaction failed", code: -1)
        }
    }
}
