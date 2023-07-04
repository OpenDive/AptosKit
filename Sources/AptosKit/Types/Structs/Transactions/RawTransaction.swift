//
//  RawTransaction.swift
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
import CryptoSwift

public struct RawTransaction: KeyProtocol, Equatable {
    /// The sender of the transaction
    public var sender: AccountAddress

    /// The sequence number (number of transactions) for the sender account
    public var sequenceNumber: UInt64

    /// The contents of the transaction itself (e.g., the program)
    public var payload: TransactionPayload

    /// The maximum gas amount is the maximum gas units the transaction is allowed to consume.
    public var maxGasAmount: UInt64

    /// This is the amount the sender is willing to pay per unit of gas to execute the transaction. Gas is a way to pay for computation and storage. A gas unit is an abstract measurement of computation with no inherent real-world value.
    public var gasUnitPrice: UInt64

    /// A timestamp after which the transaction ceases to be valid (i.e., expires).
    public var expirationTimestampSecs: UInt64

    /// An identifier that distinguishes the Aptos network deployments (to prevent cross-network attacks).
    public var chainId: UInt8
    
    public init(
        sender: AccountAddress,
        sequenceNumber: UInt64,
        payload: TransactionPayload,
        maxGasAmount: UInt64,
        gasUnitPrice: UInt64,
        expirationTimestampSecs: UInt64,
        chainId: UInt8
    ) {
        self.sender = sender
        self.sequenceNumber = sequenceNumber
        self.payload = payload
        self.maxGasAmount = maxGasAmount
        self.gasUnitPrice = gasUnitPrice
        self.expirationTimestampSecs = expirationTimestampSecs
        self.chainId = chainId
    }

    public static func == (lhs: RawTransaction, rhs: RawTransaction) -> Bool {
        return
            lhs.sender == rhs.sender &&
            lhs.sequenceNumber == rhs.sequenceNumber &&
            lhs.payload == rhs.payload &&
            lhs.maxGasAmount == rhs.maxGasAmount &&
            lhs.gasUnitPrice == rhs.gasUnitPrice &&
            lhs.expirationTimestampSecs == rhs.expirationTimestampSecs &&
            lhs.chainId == rhs.chainId
    }

    /// Compute the SHA3-256 hash of a string representation of a transaction.
    ///
    /// This function computes the SHA3-256 hash of the string "APTOS::RawTransaction", which serves as a prefix to the transaction data, and returns the result.
    ///
    /// - Returns: A Data object containing the SHA3-256 hash of the string "APTOS::RawTransaction".
    ///
    /// - Throws: An AptosError object indicating that the conversion from string to Data object has failed.
    public func prehash() throws -> Data {
        guard let data = "APTOS::RawTransaction".data(using: .utf8) else {
            throw AptosError.stringToDataFailure(value: "APTOS::RawTransaction")
        }
        return data.sha3(.sha256)
    }

    /// Serialize and hash a transaction for signing.
    ///
    /// This function serializes the transaction using a Serializer instance, computes the SHA3-256 hash of the serialized transaction concatenated with a prehash, and returns the result.
    ///
    /// - Returns: A Data object containing the SHA3-256 hash of the serialized transaction concatenated with a prehash.
    ///
    /// - Throws: An error of type AptosError indicating that the serialization or prehash computation has failed.
    public func keyed() throws -> Data {
        let ser = Serializer()
        try self.serialize(ser)
        var prehash = try self.prehash()
        prehash.append(ser.output())
        return prehash
    }

    /// Sign the transaction using the provided private key.
    ///
    /// This function signs the transaction using the provided private key and returns the resulting signature.
    ///
    /// - Parameters:
    /// - key: A PrivateKey object to be used for signing the transaction.
    ///
    /// - Returns: A Signature object containing the signature of the transaction.
    ///
    /// - Throws: An error of type Ed25519Error indicating that the signing operation has failed.
    public func sign(_ key: PrivateKey) throws -> Signature {
        return try key.sign(data: self.keyed())
    }

    /// Verify the signature of the transaction using the provided public key.
    ///
    /// This function verifies the signature of the transaction using the provided public key and returns a Boolean value indicating whether the signature is valid or not.
    ///
    /// - Parameters:
    /// - key: A PublicKey object to be used for verifying the signature of the transaction.
    /// - signature: A Signature object containing the signature to be verified.
    ///
    /// - Returns: A Boolean value indicating whether the signature is valid or not.
    ///
    /// - Throws: An error of type Ed25519Error indicating that the verification operation has failed.
    public func verify(_ key: PublicKey, _ signature: Signature) throws -> Bool {
        return try key.verify(data: self.keyed(), signature: signature)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> RawTransaction {
        return RawTransaction(
            sender: try AccountAddress.deserialize(from: deserializer),
            sequenceNumber: try Deserializer.u64(deserializer),
            payload: try TransactionPayload.deserialize(from: deserializer),
            maxGasAmount: try Deserializer.u64(deserializer),
            gasUnitPrice: try Deserializer.u64(deserializer),
            expirationTimestampSecs: try Deserializer.u64(deserializer),
            chainId: try Deserializer.u8(deserializer)
        )
    }

    public func serialize(_ serializer: Serializer) throws {
        try self.sender.serialize(serializer)
        try Serializer.u64(serializer, self.sequenceNumber)
        try self.payload.serialize(serializer)
        try Serializer.u64(serializer, self.maxGasAmount)
        try Serializer.u64(serializer, self.gasUnitPrice)
        try Serializer.u64(serializer, self.expirationTimestampSecs)
        try Serializer.u8(serializer, self.chainId)
    }
}
