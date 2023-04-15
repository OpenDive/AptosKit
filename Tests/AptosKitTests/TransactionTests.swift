//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/14/23.
//

import XCTest
@testable import AptosKit

final class TransactionTests: XCTestCase {
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
}
