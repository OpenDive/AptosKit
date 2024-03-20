//
//  File.swift
//  
//
//  Created by Marcus Arnett on 3/20/24.
//

import Foundation

public protocol RawTransactionInternal: KeyProtocol {
    func keyed() throws -> Data

    func prehash() throws -> Data

    func sign(key: any PrivateKeyProtocol) throws -> Signature

    func verify(key: any PublicKeyProtocol, signature: Signature) throws -> Bool
}

public protocol RawTransactionWithData: RawTransactionInternal {
    var rawTransaction: RawTransaction { get set }

    func inner() -> RawTransaction

    func prehash() throws -> Data
}

extension RawTransactionWithData {
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
}

extension RawTransactionInternal {
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
        var prehash = [UInt8](try self.prehash())
        prehash.append(contentsOf: [UInt8](ser.output()))
        return Data(prehash)
    }

    public func prehash() throws -> Data {
        throw AptosError.notImplemented
    }

    public func serialize(_ serializer: Serializer) throws {
        throw AptosError.notImplemented
    }

    public static func deserialize(from deserializer: Deserializer) throws -> RawTransactionInternal {
        throw AptosError.notImplemented
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
    public func sign(key: any PrivateKeyProtocol) throws -> Signature {
        return try key.sign(data: try self.keyed())
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
    public func verify(key: any PublicKeyProtocol, signature: Signature) throws -> Bool {
        return try key.verify(data: try self.keyed(), signature: signature)
    }
}
