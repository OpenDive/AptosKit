//
//  SignedTransaction.swift
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

/// Aptos Blockchain Signed Transaction
public struct SignedTransaction: KeyProtocol, Equatable {
    /// The transaction itself
    public var transaction: RawTransaction

    /// The authenticator used to sign the transaction
    public var authenticator: Authenticator

    /// Outputs the SignedTransaction object itself into a serialized Data object output
    /// - Returns: A Data object
    public func bytes() throws -> Data {
        let ser = Serializer()
        try Serializer._struct(ser, value: self)
        return ser.output()
    }

    /// Verify a signed transaction using the associated authenticator.
    ///
    /// This function verifies the signed transaction using the associated authenticator.
    ///
    /// - Returns: A Boolean value indicating whether the transaction is valid or not.
    ///
    /// - Throws: An error of type AuthenticatorError indicating that the transaction cannot be verified.
    public func verify() throws -> Bool {
        var keyed: Data

        if self.authenticator.authenticator is MultiAgentAuthenticator {
            let transaction = MultiAgentRawTransaction(
                rawTransaction: self.transaction,
                secondarySigners: (self.authenticator.authenticator as! MultiAgentAuthenticator).secondaryAddresses()
            )
            keyed = try transaction.keyed()
        } else {
            keyed = try self.transaction.keyed()
        }

        return try self.authenticator.verify(keyed)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SignedTransaction {
        let transaction = try RawTransaction.deserialize(from: deserializer)
        let authenticator = try Authenticator.deserialize(from: deserializer)
        return SignedTransaction(transaction: transaction, authenticator: authenticator)
    }

    public func serialize(_ serializer: Serializer) throws {
        try self.transaction.serialize(serializer)
        try self.authenticator.serialize(serializer)
    }
}
