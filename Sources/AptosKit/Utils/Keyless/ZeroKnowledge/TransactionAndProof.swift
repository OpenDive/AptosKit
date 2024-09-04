//
//  TransactionAndProof.swift
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

/// A container class to hold a transaction and a proof.  It implements CryptoHashable which is used to create
/// the signing message for Keyless transactions.  We sign over the proof to ensure non-malleability.
public struct TransactionAndProof: RawTransactionWithData {
    /// The domain separator prefix used when hashing.
    public let domainSeparator = "APTOS::TransactionAndProof"

    /// The transaction to sign.
    public var rawTransaction: RawTransaction

    /// The zero knowledge proof used in signing the transaction.
    public var proof: ZkProof?

    public init(transaction: RawTransaction, proof: ZkProof? = nil) {
        self.rawTransaction = transaction
        self.proof = proof
    }

    public func prehash() throws -> Data {
        guard let data = self.domainSeparator.data(using: .utf8) else {
            throw AptosError.stringToDataFailure(value: self.domainSeparator)
        }
        return data.sha3(.sha256)
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.fixedBytes(self.rawTransaction.bcsBytes())
        try serializer.optional(Serializer._struct, self.proof)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionAndProof {
        throw AptosError.notImplemented
    }
}
