//
//  File.swift
//  
//
//  Created by Marcus Arnett on 3/18/24.
//

import Foundation
import AptosKit

struct RotateKey {
    let width: Int = 19

    static func rotationPayload(
        fromKey: ED25519PublicKey,
        toKey: ED25519PublicKey,
        fromSignature: Signature,
        toSignature: Signature
    ) throws -> TransactionPayload {
        let fromScheme = try Authenticator.fromKey(key: fromKey)
        let toScheme = try Authenticator.fromKey(key: toKey)

        let entryFunction = try EntryFunction.natural(
            "0x1::account",
            "rotate_authentication_key",
            [],
            [
                AnyTransactionArgument(TransactionArgument(value: UInt8(fromScheme), encoder: Serializer.u8)),
                AnyTransactionArgument(TransactionArgument(value: fromKey.key, encoder: Serializer.toBytes)),
                AnyTransactionArgument(TransactionArgument(value: UInt8(toScheme), encoder: Serializer.u8)),
                AnyTransactionArgument(TransactionArgument(value: toKey.key, encoder: Serializer.toBytes)),
                AnyTransactionArgument(TransactionArgument(value: fromSignature, encoder: Serializer._struct)),
                AnyTransactionArgument(TransactionArgument(value: toSignature, encoder: Serializer._struct))
            ]
        )

        return try TransactionPayload(payload: entryFunction)
    }
    
    static func rotationPayload(
        fromKey: ED25519PublicKey,
        toKey: MultiED25519PublicKey,
        fromSignature: Signature,
        toSignature: MultiSignature
    ) throws -> TransactionPayload {
        let fromScheme = try Authenticator.fromKey(key: fromKey)
        let toScheme = try Authenticator.fromKey(key: toKey)

        let entryFunction = try EntryFunction.natural(
            "0x1::account",
            "rotate_authentication_key",
            [],
            [
                AnyTransactionArgument(TransactionArgument(value: UInt8(fromScheme), encoder: Serializer.u8)),
                AnyTransactionArgument(TransactionArgument(value: fromKey.key, encoder: Serializer.toBytes)),
                AnyTransactionArgument(TransactionArgument(value: UInt8(toScheme), encoder: Serializer.u8)),
                AnyTransactionArgument(TransactionArgument(value: toKey.toBytes(), encoder: Serializer.toBytes)),
                AnyTransactionArgument(TransactionArgument(value: fromSignature, encoder: Serializer._struct)),
                AnyTransactionArgument(TransactionArgument(value: toSignature, encoder: Serializer._struct))
            ]
        )

        return try TransactionPayload(payload: entryFunction)
    }
    
    static func rotateAuthKeyEd25519Payload(
        restClient: RestClient,
        fromAccount: Account,
        privateKey: ED25519PrivateKey
    ) async throws -> TransactionPayload {
        let toAccount = try Account.loadKey(privateKey.hex())
        let sequenceNumber = try await restClient.accountSequenceNumber(fromAccount.address())
        let rotationProofChallenge = try RotatingProofChallenge(
            sequence_number: sequenceNumber,
            originator: fromAccount.address(),
            currentAuthKey: try AccountAddress.fromStrRelaxed(fromAccount.authKey()),
            newPublicKey: try toAccount.publicKey().key
        )

        let ser = Serializer()
        try rotationProofChallenge.serialize(ser)
        let rotationProofChallengeBcs = ser.output()
        
        let fromSignature = try fromAccount.sign(rotationProofChallengeBcs)
        let toSignature = try toAccount.sign(rotationProofChallengeBcs)
        
        return try Self.rotationPayload(
            fromKey: try fromAccount.publicKey(),
            toKey: try toAccount.publicKey(),
            fromSignature: fromSignature,
            toSignature: toSignature
        )
    }

    static func rotateAuthKeyMultiEd25519Payload(
        restClient: RestClient,
        fromAccount: Account,
        privateKeys: [ED25519PrivateKey]
    ) async throws -> TransactionPayload {
        let toAccounts = try privateKeys.compactMap { try Account.loadKey($0.hex()) }
        let publicKeys = try privateKeys.compactMap { try $0.publicKey() }
        let publicKey = try MultiED25519PublicKey(keys: publicKeys, threshold: 1)
        let sequenceNumber = try await restClient.accountSequenceNumber(fromAccount.address())
        
        let rotationProofChallenge = try RotatingProofChallenge(
            sequence_number: sequenceNumber,
            originator: fromAccount.address(),
            currentAuthKey: try AccountAddress.fromStr(try fromAccount.authKey()),
            newPublicKey: publicKey.toBytes()
        )
        
        let ser = Serializer()
        try rotationProofChallenge.serialize(ser)
        let rotationProofChallengeBcs = ser.output()
        
        let fromSignature = try fromAccount.sign(rotationProofChallengeBcs)
        let toSignature = try toAccounts[0].sign(rotationProofChallengeBcs)
        let multiToSignature = MultiSignature(
            publicKey: publicKey,
            signatureMap: [(try toAccounts[0].publicKey(), toSignature)]
        )
        
        return try Self.rotationPayload(
            fromKey: try fromAccount.publicKey(),
            toKey: publicKey,
            fromSignature: fromSignature,
            toSignature: multiToSignature
        )
    }

    static func rotateKeyTest() async throws {
        // MARK: Section 1
        let restClient = try await RestClient(baseUrl: "https://fullnode.devnet.aptoslabs.com/v1")
        let faucetClient = FaucetClient(
            baseUrl: "https://faucet.devnet.aptoslabs.com",
            restClient: restClient
        )

        // MARK: Section 2
        var alice = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english)).account
        let bob = try Wallet(mnemonic: Mnemonic(wordcount: 12, wordlist: Wordlists.english)).account

        print("\n=== Addresses ===")
        print("Alice: \(alice.address().description)")
        print("Bob: \(bob.address().description)")

        // MARK: Section 3
        let _ = try await faucetClient.fundAccount(
            alice.address().description,
            100_000_000
        )

        print("\n=== Initial Coin Balances ===")
        let aliceBalance = try await restClient.accountBalance(
            alice.address()
        )

        print("Alice: \(aliceBalance)")

        print("\n...rotating...\n")

        // :!:>rotate_key
        // Create the payload for rotating Alice's private key to Bob's private key
        var payload = try await Self.rotateAuthKeyEd25519Payload(
            restClient: restClient,
            fromAccount: alice,
            privateKey: bob.privateKey
        )

        // Have Alice sign the transaction with the payload
        var signedTransaction = try await restClient.createBcsSignedTransaction(alice, payload)

        // Submit the transaction and wait for confirmation
        var txHash = try await restClient.submitBcsTransaction(signedTransaction)
        try await restClient.waitForTransaction(txHash)

        // Check the authentication key for Alice's address on-chain
        var aliceNewAccountInfo = try await restClient.account(alice.address())

        print("ALICE NEW AUTH KEY - \(aliceNewAccountInfo.authenticationKey)")
        print("BOB'S PREVIOUS AUTH KEY - \(try bob.authKey())")

        // Construct a new Account object that reflects alice's original address with the new private key
        let originalAliceKey = alice.privateKey
        alice = Account(accountAddress: alice.accountAddress, privateKey: bob.privateKey)

        print("\n...rotating...\n")
        payload = try await Self.rotateAuthKeyMultiEd25519Payload(
            restClient: restClient,
            fromAccount: alice,
            privateKeys: [bob.privateKey, originalAliceKey]
        )
        signedTransaction = try await restClient.createBcsSignedTransaction(alice, payload)
        txHash = try await restClient.submitBcsTransaction(signedTransaction)
        try await restClient.waitForTransaction(txHash)

        aliceNewAccountInfo = try await restClient.account(alice.address())
        let authKey = aliceNewAccountInfo.authenticationKey
        print("Rotation to MultiPublicKey complete, new authkey: \(authKey)")
    }
}
