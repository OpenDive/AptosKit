//
//  File.swift
//  
//
//  Created by Marcus Arnett on 3/18/24.
//

import Foundation

public protocol PublicKeyProtocol: KeyProtocol, CustomStringConvertible, Hashable {
    /// The type of data value that represents the key.
    associatedtype DataValue: KeyValueProtocol

    /// The actual public key data.
    var key: DataValue { get set }

    /// Verify a digital signature for a given data using the key's corresponding algorithm.
    ///
    /// This function verifies a digital signature provided by the key's corresponding algorithm for a given data and public key.
    /// - Parameters:
    ///    - data: The Data object to be verified.
    ///    - signature: The Signature object containing the signature to be verified.
    ///
    /// - Returns: A Boolean value indicating whether the signature is valid or not.
    /// - Throws: An error of type invalidSignature if the signature is invalid or an error occurred during verification.
    func verify(data: Data, signature: Signature) throws -> Bool

    /// Verify a digital signature for a given data using the key's corresponding algorithm.
    ///
    /// This function verifies a digital signature provided by the key's corresponding algorithm for a given data and public key.
    /// - Parameters:
    ///    - data: The Data object to be verified.
    ///    - signature: The MultiSignature object containing the signature to be verified.
    ///
    /// - Returns: A Boolean value indicating whether the signature is valid or not.
    /// - Throws: An error of type invalidSignature if the signature is invalid or an error occurred during verification.
    func verify(data: Data, signature: MultiSignature) throws -> Bool
}

extension PublicKeyProtocol {
    public func verify(data: Data, signature: Signature) throws -> Bool {
        throw AptosError.notImplemented
    }

    public func verify(data: Data, signature: MultiSignature) throws -> Bool {
        throw AptosError.notImplemented
    }
}
