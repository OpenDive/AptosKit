//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/14/23.
//

import XCTest
@testable import AptosKit

final class TransactionTests: XCTestCase {
    private func verifyTransaction(
        _ rawTransactionInput: String,
        _ rawTransactionGenerated: RawTransaction,
        _ signedTransactionInput: String,
        _ signedTransactionGenerated: SignedTransaction
    ) throws {
        var ser = Serializer()
        try Serializer._struct(ser, value: rawTransactionGenerated)
        let rawTransactionGeneratedBytes = ser.output().hexEncodedString()
        
        ser = Serializer()
        try Serializer._struct(ser, value: signedTransactionGenerated)
        let signedTransactionGeneratedBytes = ser.output().hexEncodedString()
        
        
        XCTAssertEqual(rawTransactionInput, rawTransactionGeneratedBytes)
        let rawTransactionInputData = Data(hex:rawTransactionInput)
        let rawTransaction = try RawTransaction.deserialize(
            from: Deserializer(data: rawTransactionInputData)
        )
        XCTAssertEqual(rawTransactionGenerated, rawTransaction)
        
        XCTAssertEqual(signedTransactionInput, signedTransactionGeneratedBytes)
        let signedTransactionInputData = Data(hex: signedTransactionInput)
        let signedTransaction = try SignedTransaction.deserialize(
            from: Deserializer(data: signedTransactionInputData)
        )
        
        XCTAssertEqual(signedTransaction.transaction, rawTransaction)
        XCTAssertEqual(signedTransaction, signedTransactionGenerated)
        XCTAssertTrue(try signedTransaction.verify())
    }
    
    func testThatEntryFunctionWorksAsExpected() throws {
        let privateKeyFrom = try PrivateKey.random()
        let publicKeyFrom = try privateKeyFrom.publicKey()
        let accountAddressFrom = try AccountAddress.fromKey(publicKeyFrom)
        
        let privateKeyTo = try PrivateKey.random()
        let publicKeyTo = try privateKeyTo.publicKey()
        let accountAddressTo = try AccountAddress.fromKey(publicKeyTo)
        
        let transactionArguments = [
            TransactionArgument(value: accountAddressTo, encoder: Serializer._struct),
            TransactionArgument(value: UInt64(5000), encoder: Serializer.u64)
        ]
        
        let typeTagValue = try StructTag.fromStr("0x1::aptos_coin::AptosCoin")

        let payload = try EntryFunction.natural(
            "0x1::coin",
            "transfer",
            [TypeTag(value:
                typeTagValue
             )
            ],
            transactionArguments
        )
        
        let rawTransaction = try RawTransaction(
            sender: accountAddressFrom,
            sequenceNumber: 0,
            payload: TransactionPayload(payload: payload),
            maxGasAmount: 2000,
            gasUnitPrice: 0,
            expirationTimestampSecs: UInt64(18446744073709551615),
            chainId: 4
        )

        let signature = try rawTransaction.sign(privateKeyFrom)

        XCTAssertTrue(
            try rawTransaction.verify(publicKeyFrom, signature)
        )

        let authenticator = Authenticator(
            authenticator: Ed25519Authenticator(
                publicKey: publicKeyFrom,
                signature: signature
            )
        )
        let signedTransaction = SignedTransaction(
            transaction: rawTransaction,
            authenticator: authenticator
        )
        XCTAssertTrue(try signedTransaction.verify())
    }
    
    func testThatEntryFunctionWorksOnCorpus() throws {
        let senderKeyInput =
            "9bf49a6a0755f953811fce125f2683d50429c3bb49e074147e0089a52eae155f"
        let receiverKeyInput =
            "0564f879d27ae3c02ce82834acfa8c793a629f2ca0de6919610be82f411326be"
        
        let sequenceNumberInput: UInt64 = 11
        let gasUnitPriceInput: UInt64 = 1
        let maxGasAmountInput: UInt64 = 2000
        let expirationTimestampsSecsInput: UInt64 = 1234567890
        let chainIdInput: UInt8 = 4
        let amountInput: UInt64 = 5000
        
        let senderPrivateKey = PrivateKey.fromHex(senderKeyInput)
        let senderPublicKey = try senderPrivateKey.publicKey()
        let senderAccountAddress = try AccountAddress.fromKey(senderPublicKey)
        
        let receiverPrivateKey = PrivateKey.fromHex(receiverKeyInput)
        let receiverPublicKey = try receiverPrivateKey.publicKey()
        let receiverAccountAddress =
            try AccountAddress.fromKey(receiverPublicKey)
        
        let transactionArguments = [
            TransactionArgument(
                value: receiverAccountAddress,
                encoder: Serializer._struct
            ),
            TransactionArgument(value: amountInput, encoder: Serializer.u64)
        ]
        
        let typeTag = TypeTag(value:
            try StructTag.fromStr("0x1::aptos_coin::AptosCoin")
        )
        
        let payload = try EntryFunction.natural(
            "0x1::coin",
            "transfer",
            [typeTag],
            transactionArguments
        )
        
        let rawTransactionGenerated = RawTransaction(
            sender: senderAccountAddress,
            sequenceNumber: sequenceNumberInput,
            payload: try TransactionPayload(payload: payload),
            maxGasAmount: maxGasAmountInput,
            gasUnitPrice: gasUnitPriceInput,
            expirationTimestampSecs: expirationTimestampsSecsInput,
            chainId: chainIdInput
        )
        
        let signature = try rawTransactionGenerated.sign(senderPrivateKey)
        XCTAssertTrue(try rawTransactionGenerated.verify(senderPublicKey, signature))
        
        let authenticator = Authenticator(
            authenticator: Ed25519Authenticator(
                publicKey: senderPublicKey,
                signature: signature
            )
        )
        let signedTransacrtionGenerated = SignedTransaction(
            transaction: rawTransactionGenerated,
            authenticator: authenticator
        )
        XCTAssertTrue(try signedTransacrtionGenerated.verify())
        
        let rawTransactionInput =
            "7deeccb1080854f499ec8b4c1b213b82c5e34b925cf6875fec02d4b77adbd2d60b0000000000000002000000000000000000000000000000000000000000000000000000000000000104636f696e087472616e73666572010700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e0002202d133ddd281bb6205558357cc6ac75661817e9aaeac3afebc32842759cbf7fa9088813000000000000d0070000000000000100000000000000d20296490000000004"
        let signedTransactionInput =
            "7deeccb1080854f499ec8b4c1b213b82c5e34b925cf6875fec02d4b77adbd2d60b0000000000000002000000000000000000000000000000000000000000000000000000000000000104636f696e087472616e73666572010700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e0002202d133ddd281bb6205558357cc6ac75661817e9aaeac3afebc32842759cbf7fa9088813000000000000d0070000000000000100000000000000d202964900000000040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a4920040f25b74ec60a38a1ed780fd2bef6ddb6eb4356e3ab39276c9176cdf0fcae2ab37d79b626abb43d926e91595b66503a4a3c90acbae36a28d405e308f3537af720b"
        
        try verifyTransaction(
            rawTransactionInput,
            rawTransactionGenerated,
            signedTransactionInput,
            signedTransacrtionGenerated
        )
    }
}
