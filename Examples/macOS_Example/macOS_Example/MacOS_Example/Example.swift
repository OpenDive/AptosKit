//
//  AptosTokenExample.swift
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

@main
struct MacOSExample {
    static func tokenClientTest() async throws {
        let restClient = try await RestClient(baseUrl: "https://fullnode.devnet.aptoslabs.com/v1")
        let faucetClient = FaucetClient(
            baseUrl: "https://faucet.devnet.aptoslabs.com",
            restClient: restClient
        )
        let tokenClient = AptosTokenClient(client: restClient)

        let alice = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))

        let collectionName = "Alice's"
        let tokenName = "Alice's first token"

        print("\n=== Addresses ===")
        print("Alice: \(alice.account.address().description)")

        let _ = try await faucetClient.fundAccount(
            alice.account.address().description,
            100_000_000
        )

        print("\n=== Initial Coin Balances ===")
        let aliceBalance = try await restClient.accountBalance(
            alice.account.address()
        )
        print("Alice: \(aliceBalance)")

        print("\n=== Creating Collection and Token ===")
        let txnHashCreateCollection = try await tokenClient.createCollection(
            alice.account,
            "Alice's simple collection",
            1,
            collectionName,
            "https://aptos.dev",
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            0,
            1
        )
        try await restClient.waitForTransaction(txnHashCreateCollection)

        // This is a hack, once we add support for reading events or indexer, this will be easier
        let resp = try await restClient.accountResource(alice.account.address(), "0x1::account::Account")
        let creationNum = resp["data"]["guid_creation_num"].intValue

        let txnHashMintToken = try await tokenClient.mintToken(
            alice.account,
            collectionName,
            "Alice's simple token",
            tokenName,
            "https://aptos.dev/img/nyan.jpeg",
            PropertyMap(
                properties: [
                    Property.string("string", "string value")
                ]
            )
        )
        try await restClient.waitForTransaction(txnHashMintToken)

        let collectionAddr = try AccountAddress.forNamedCollection(
            alice.account.address(),
            collectionName
        )
        let tokenAddr = try AccountAddress.forGuidObject(alice.account.address(), creationNum)

        let collectionData = try await tokenClient.readObject(address: collectionAddr)
        print("Alice's collection: \(collectionData)\n")

        let tokenData = try await tokenClient.readObject(address: tokenAddr)
        print("Alice's token (Original): \(tokenData)\n")

        // MARK: Add Token Property (Bool)
        let txnHashAddTokenProperty = try await tokenClient.addTokenProperty(
            alice.account,
            tokenAddr,
            Property.bool("test", false)
        )
        try await restClient.waitForTransaction(txnHashAddTokenProperty)
        let tokenDataAddProperty = try await tokenClient.readObject(address: tokenAddr)
        print("Alice's token (Add Property): \(tokenDataAddProperty)\n")

        // MARK: Remove Token Property
        let txnHashRemoveTokenProperty = try await tokenClient.removeTokenProperty(
            alice.account,
            tokenAddr,
            "string"
        )
        try await restClient.waitForTransaction(txnHashRemoveTokenProperty)
        let tokenDataRemoveProperty = try await tokenClient.readObject(address: tokenAddr)
        print("Alice's token (Remove Property): \(tokenDataRemoveProperty)\n")

        // MARK: Update Token Property
        let txnHashUpdateTokenProperty = try await tokenClient.updateTokenProperty(
            alice.account,
            tokenAddr,
            Property.bool("test", true)
        )
        try await restClient.waitForTransaction(txnHashUpdateTokenProperty)
        let tokenDataUpdateProperty = try await tokenClient.readObject(address: tokenAddr)
        print("Alice's token (Update Property): \(tokenDataUpdateProperty)\n")

        // MARK: Add Token Property (Data)
        let byteArray: [UInt8] = [0x00, 0x01]
        let data = Data(byteArray)
        let txnHashAddTokenPropertyData = try await tokenClient.addTokenProperty(
            alice.account,
            tokenAddr,
            Property.bytes("bytes", data)
        )
        try await restClient.waitForTransaction(txnHashAddTokenPropertyData)
        let tokenDataAddPropertyData = try await tokenClient.readObject(address: tokenAddr)
        print("Alice's token (Add Property Data): \(tokenDataAddPropertyData)\n")
    }

    static func main() async throws {
        try await MacOSExample.tokenClientTest()
    }
}
