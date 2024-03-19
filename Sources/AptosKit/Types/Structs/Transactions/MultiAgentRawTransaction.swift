//
//  MultiAgentRawTransaction.swift
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

/// Aptos Blockchain Multi-Agent Raw Transaction
public struct MultiAgentRawTransaction {
    /// The raw transaction itself
    public var rawTransaction: RawTransaction

    /// The other parties involved
    public var secondarySigners: [AccountAddress]

    /// Returns the Multi-Agent's raw transaction
    /// - Returns: A RawTransaction object
    public func inner() -> RawTransaction {
        return self.rawTransaction
    }

    /// Compute the SHA3-256 hash of a string representation of a transaction with data.
    ///
    /// This function computes the SHA3-256 hash of the string "APTOS::RawTransactionWithData", which serves as a prefix to the transaction data, and returns the result.
    ///
    /// - Returns: A Data object containing the SHA3-256 hash of the string "APTOS::RawTransactionWithData".
    ///
    /// - Throws: An AptosError object indicating that the conversion from string to Data object has failed.
    public func prehash() throws -> Data {
        guard let data = "APTOS::RawTransactionWithData".data(using: .utf8) else {
            throw AptosError.stringToDataFailure(value: "APTOS::RawTransactionWithData")
        }
        return data.sha3(.sha256)
    }

    /// Serialize and hash a multi-agent raw transaction for signing.
    ///
    /// This function serializes the multi-agent raw transaction using a Serializer instance, computes the SHA3-256 hash of the serialized transaction concatenated with a prehash, and returns the result.
    ///
    /// - Returns: A Data object containing the SHA3-256 hash of the serialized transaction concatenated with a prehash.
    ///
    /// - Throws: An error of type AptosError indicating that the serialization or prehash computation has failed.
    public func keyed() throws -> Data {
        let ser = Serializer()
        try Serializer.u8(ser, UInt8(0))
        try Serializer._struct(ser, value: self.rawTransaction)
        try ser.sequence(self.secondarySigners, Serializer._struct)
        var prehash = Array(try prehash()).map { Data([$0]) }
        prehash.append(ser.output())
        return prehash.reduce(Data(), { $0 + $1 })
    }

    /// Sign the multi-agent raw transaction using the provided private key.
    ///
    /// This function signs the multi-agent raw transaction using the provided private key and returns the resulting signature.
    ///
    /// - Parameters:
    /// - key: A PrivateKey object to be used for signing the multi-agent raw transaction.
    ///
    /// - Returns: A Signature object containing the signature of the multi-agent raw transaction.
    ///
    /// - Throws: An error of type Ed25519Error indicating that the signing operation has failed.
    public func sign(_ key: ED25519PrivateKey) throws -> Signature {
        return try key.sign(data: self.keyed())
    }

    /// Verify the signature of the multi-agent raw transaction using the provided public key.
    ///
    /// This function verifies the signature of the multi-agent raw transaction using the provided public key and returns a Boolean value indicating whether the signature is valid or not.
    ///
    /// - Parameters:
    /// - key: A PublicKey object to be used for verifying the signature of the multi-agent raw transaction.
    /// - signature: A Signature object containing the signature to be verified.
    ///
    /// - Returns: A Boolean value indicating whether the signature is valid or not.
    ///
    /// - Throws: An error of type Ed25519Error indicating that the verification operation has failed.
    public func verify(_ key: ED25519PublicKey, _ signature: Signature) throws -> Bool {
        return try key.verify(data: self.keyed(), signature: signature)
    }
}
