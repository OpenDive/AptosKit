//
//  Multisig.swift
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

struct Multisig {
    static func multisigTest() async throws {
        let restClient = try await RestClient(baseUrl: "https://fullnode.devnet.aptoslabs.com/v1")
        let faucetClient = FaucetClient(
            baseUrl: "https://faucet.devnet.aptoslabs.com",
            restClient: restClient
        )

        // MARK: Section 1
        let alice = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        let bob = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))
        let chad = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))

        print("\n=== Account addresses ===")
        print("Alice: \(alice.account.address())")
        print("Bob: \(bob.account.address())")
        print("Chad: \(chad.account.address())")

        print("\n=== Authentication keys ===")
        print("Alice: \(try alice.account.authKey())")
        print("Bob: \(try bob.account.authKey())")
        print("Chad: \(try chad.account.authKey())")

        print("\n=== Public keys ===")
        print("Alice: \(try alice.account.publicKey())")
        print("Bob: \(try bob.account.publicKey())")
        print("Chad: \(try chad.account.publicKey())")

        // MARK: Section 2
        let threshold = 2

        let multisigPublicKey = try MultiED25519PublicKey(
            keys: [
                try alice.account.publicKey(),
                try bob.account.publicKey(),
                try chad.account.publicKey()
            ],
            threshold: threshold
        )
        let multisigAddress = try AccountAddress.fromMultiEd25519(keys: multisigPublicKey)

        print("\n=== 2-of-3 Multisig account ===")
        print("Account public key: \(multisigPublicKey)")
        print("Account address: \(multisigAddress)")

        // MARK: Section 3
        print("\n=== Funding accounts ===")
        let aliceStart = 10_000_000
        let bobStart = 20_000_000
        let chadStart = 30_000_000
        let multisigStart = 40_000_000

        try await faucetClient.fundAccount(
            alice.account.address().description,
            aliceStart
        )
        var aliceBalance = try await restClient.accountBalance(alice.account.address())
        print("Alice's balance: \(aliceBalance)")

        try await faucetClient.fundAccount(
            bob.account.address().description,
            bobStart
        )
        var bobBalance = try await restClient.accountBalance(bob.account.address())
        print("Bob's balance: \(bobBalance)")

        try await faucetClient.fundAccount(
            chad.account.address().description,
            chadStart
        )
        var chadBalance = try await restClient.accountBalance(chad.account.address())
        print("Chad's balance: \(chadBalance)")

        try await faucetClient.fundAccount(
            multisigAddress.description,
            multisigStart
        )
        var multisigBalance = try await restClient.accountBalance(multisigAddress)
        print("Multisig balance: \(multisigBalance)")

        // MARK: Section 4
        let entryFunctionTransfer = try EntryFunction.natural(
            "0x1::coin",
            "transfer",
            [TypeTag(value: try StructTag.fromStr("0x1::aptos_coin::AptosCoin"))],
            [
                AnyTransactionArgument(TransactionArgument(value: chad.account.address(), encoder: Serializer._struct)),
                AnyTransactionArgument(TransactionArgument(value: UInt64(100), encoder: Serializer.u64))
            ]
        )

        let rawTransaction = RawTransaction(
            sender: multisigAddress,
            sequenceNumber: UInt64(0),
            payload: try TransactionPayload(payload: entryFunctionTransfer),
            maxGasAmount: UInt64(restClient.clientConfig.maxGasAmount),
            gasUnitPrice: UInt64(restClient.clientConfig.gasUnitPrice),
            expirationTimestampSecs: UInt64(Date().timeIntervalSince1970 + Double(restClient.clientConfig.expirationTtl)),
            chainId: UInt8(restClient.chainId)
        )

        let aliceSignature = try alice.account.sign(rawTransaction.keyed())
        let bobSignature = try bob.account.sign(rawTransaction.keyed())

        guard try rawTransaction.verify(alice.account.publicKey(), aliceSignature) else {
            throw NSError(domain: "Raw Transaction Verification Failed For Alice", code: -1)
        }
        guard try rawTransaction.verify(bob.account.publicKey(), bobSignature) else {
            throw NSError(domain: "Raw Transaction Verification Failed For Bob", code: -1)
        }

        print("\n=== Individual signatures ===")
        print("Alice: \(aliceSignature)")
        print("Bob: \(bobSignature)")

        // MARK: Section 5
        // Map from signatory public key to signature.
        let sigMap = [
            (try alice.account.publicKey(), aliceSignature),
            (try bob.account.publicKey(), bobSignature)
        ]

        let multisigSignature = MultiSignature(publicKey: multisigPublicKey, signatureMap: sigMap)

        let authenticator = try Authenticator(
            authenticator: MultiEd25519Authenticator(
                publicKey: multisigPublicKey,
                signature: multisigSignature
            )
        )

        let signedTransactionSigMap = SignedTransaction(
            transaction: rawTransaction,
            authenticator: authenticator
        )

        print("\n=== Submitting transfer transaction ===")

        let txHashSubmitBcsTransaction = try await restClient.submitBcsTransaction(signedTransactionSigMap)
        try await restClient.waitForTransaction(txHashSubmitBcsTransaction)
        print("Transaction Hash: \(txHashSubmitBcsTransaction)")

        // MARK: Section 6
        print("\n=== New account balances===")

        aliceBalance = try await restClient.accountBalance(alice.account.address())
        print("Alice's balance: \(aliceBalance)")

        bobBalance = try await restClient.accountBalance(bob.account.address())
        print("Bob's balance: \(bobBalance)")

        chadBalance = try await restClient.accountBalance(chad.account.address())
        print("Chad's balance: \(chadBalance)")

        multisigBalance = try await restClient.accountBalance(multisigAddress)
        print("Multisig balance: \(multisigBalance)")

        // MARK: Section 7
        print("\n=== Funding vanity address ===")

        let deedee = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english))

        print("Deedee's address: \(deedee.account.address().description)")
        print("Deedee's public key: \(try deedee.account.publicKey().description)")

        let deedeeStart = 50_000_000

        let _ = try await faucetClient.fundAccount(deedee.account.address().description, deedeeStart)
        let deedeeBalance = try await restClient.accountBalance(deedee.account.address())
        print("Deedee's balance: \(deedeeBalance)")

        // MARK: Section 8
        print("\n=== Signing rotation proof challenge ===")

        let rotationProofChallenge = try RotatingProofChallenge(
            sequence_number: 0,
            originator: deedee.account.address(),
            currentAuthKey: deedee.account.address(),
            newPublicKey: multisigPublicKey.toBytes()
        )

        let serializer = Serializer()
        try rotationProofChallenge.serialize(serializer)
        let rotationProofChallengeBcs = serializer.output()

        let capRotateKey = try deedee.account.sign(rotationProofChallengeBcs).data()

        let capUpdateTable = MultiSignature(
            publicKey: multisigPublicKey,
            signatureMap: [
                (try bob.account.publicKey(), try bob.account.sign(rotationProofChallengeBcs)),
                (try chad.account.publicKey(), try chad.account.sign(rotationProofChallengeBcs))
            ]
        ).toBytes()

        let capRotationKeyHex = "0x\(capRotateKey.toHexString())"
        let capUpdateTableHex = "0x\(capUpdateTable.toHexString())"

        print("capRotateKey: \(capRotationKeyHex)")
        print("capUpdateTable: \(capUpdateTableHex)")

        // MARK: Section 9
        print("\n=== Submitting authentication key rotation transaction ===")

        let fromScheme = Authenticator.ed25519
        let fromPublicKeyBytes = try deedee.account.publicKey().key
        let toScheme = Authenticator.multiEd25519
        let toPublicKeyBytes = multisigPublicKey.toBytes()

        let entryFunctionRotation = try EntryFunction.natural(
            "0x1::account",
            "rotate_authentication_key",
            [],
            [
                AnyTransactionArgument(TransactionArgument(value: UInt8(fromScheme), encoder: Serializer.u8)),
                AnyTransactionArgument(TransactionArgument(value: fromPublicKeyBytes, encoder: Serializer.toBytes)),
                AnyTransactionArgument(TransactionArgument(value: UInt8(toScheme), encoder: Serializer.u8)),
                AnyTransactionArgument(TransactionArgument(value: toPublicKeyBytes, encoder: Serializer.toBytes)),
                AnyTransactionArgument(TransactionArgument(value: capRotateKey, encoder: Serializer.toBytes)),
                AnyTransactionArgument(TransactionArgument(value: capUpdateTable, encoder: Serializer.toBytes))
            ]
        )

        let signedTransactionRotation = try await restClient.createBcsSignedTransaction(
            deedee.account,
            TransactionPayload(payload: entryFunctionRotation)
        )

        var authKey = try await restClient.account(deedee.account.address()).authenticationKey

        print("Auth key pre-rotation: \(authKey)")

        let txHashRotation = try await restClient.submitBcsTransaction(signedTransactionRotation)
        try await restClient.waitForTransaction(txHashRotation)
        print("Transaction hash (rotation): \(txHashRotation)")

        authKey = try await restClient.account(deedee.account.address()).authenticationKey

        print("New auth key: \(authKey)")
        print("1st multisig address: \(multisigAddress)")
    }
}
