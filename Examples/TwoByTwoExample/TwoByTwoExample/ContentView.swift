//
//  ContentView.swift
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

import SwiftUI
import AptosKit

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, Aptos!")
        }
        .padding()
        .task {
            do {
                let restClient = try await RestClient(baseUrl: "https://fullnode.devnet.aptoslabs.com/v1")
                let faucetClient = FaucetClient(
                    baseUrl: "https://faucet.devnet.aptoslabs.com",
                    restClient: restClient
                )

                let alice = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
                let bob = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
                let carol = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
                let david = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))

                print("\n=== Addresses ===")
                print("Alice: \(alice.account.address().description)")
                print("Bob: \(bob.account.address().description)")
                print("Alice: \(carol.account.address().description)")
                print("Bob: \(david.account.address().description)")

                let _ = try await faucetClient.fundAccount(
                    alice.account.address().description,
                    100_000_000
                )
                let _ = try await faucetClient.fundAccount(
                    bob.account.address().description,
                    100_000_000
                )
                let _ = try await faucetClient.fundAccount(
                    carol.account.address().description,
                    0
                )
                let _ = try await faucetClient.fundAccount(
                    david.account.address().description,
                    0
                )

                var aliceBalance = try await restClient.accountBalance(
                    alice.account.address()
                )
                var bobBalance = try await restClient.accountBalance(
                    bob.account.address()
                )
                var carolBalance = try await restClient.accountBalance(
                    carol.account.address()
                )
                var davidBalance = try await restClient.accountBalance(
                    david.account.address()
                )

                print("\n=== Initial Coin Balances ===")
                print("Alice: \(aliceBalance)")
                print("Bob: \(bobBalance)")
                print("Carol: \(carolBalance)")
                print("David: \(davidBalance)")
                
                let scriptArguments = [
                    try ScriptArgument(ScriptArgument.u64, UInt64(100)),
                    try ScriptArgument(ScriptArgument.u64, UInt64(200)),
                    try ScriptArgument(ScriptArgument.address, carol.account.address()),
                    try ScriptArgument(ScriptArgument.address, david.account.address()),
                    try ScriptArgument(ScriptArgument.u64, UInt64(50))
                ]
                
                guard let codeUrl = Bundle.main.url(
                    forResource: "two_by_two_transfer",
                    withExtension: "mv"
                ) else {
                    throw NSError(domain: "Failed to unwrap URL file", code: -1)
                }
                let code = try Data(contentsOf: codeUrl)

                let payload = try TransactionPayload(
                    payload: Script(
                        code: code,
                        args: scriptArguments,
                        tyArgs: []
                    )
                )

                let txnMultiAgent = try await restClient.createMultiAgentBcsTransaction(
                    alice.account,
                    [bob.account],
                    payload
                )
                let txnHashMultiAgent = try await restClient.submitBcsTransaction(txnMultiAgent)
                try await restClient.waitForTransaction(txnHashMultiAgent)

                aliceBalance = try await restClient.accountBalance(
                    alice.account.address()
                )
                bobBalance = try await restClient.accountBalance(
                    bob.account.address()
                )
                carolBalance = try await restClient.accountBalance(
                    carol.account.address()
                )
                davidBalance = try await restClient.accountBalance(
                    david.account.address()
                )

                print("\n=== Final Coin Balances ===")
                print("Alice: \(aliceBalance)")
                print("Bob: \(bobBalance)")
                print("Carol: \(carolBalance)")
                print("David: \(davidBalance)")
            } catch {
                print("ERROR: \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
