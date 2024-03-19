//
//  File.swift
//  
//
//  Created by Marcus Arnett on 3/18/24.
//

import Foundation

public protocol PrivateKeyProtocol: KeyProtocol, CustomStringConvertible, Hashable {
    /// The type of the public key that corresponds to this private key.
    associatedtype PublicKeyType: PublicKeyProtocol

    /// The type of data value that represents the key.
    associatedtype DataValue: KeyValueProtocol

    /// The actual private key data.
    var key: DataValue { get }

    /// Converts the private key to a hexadecimal string.
    /// - Returns: A string representation of the private key in hexadecimal format, with a "0x" prefix.
    /// - Note: The hexEncodedString function of the Data type is called to convert the private key into a hexadecimal string, and "0x" is prepended to the resulting string.
    func hex() -> String

    /// Calculates the corresponding public key for this private key instance using the key's corresponding algorithm.
    /// - Returns: A PublicKey instance representing the public key associated with this private key.
    /// - Throws: An error if the calculation of the public key fails, or if the public key cannot be used to create a PublicKey instance.
    func publicKey() throws -> PublicKeyType

    /// Signs a message using this private key and the key's corresponding algorithm.
    /// - Parameter data: The message to be signed.
    /// - Returns: A Signature instance representing the signature for the message.
    /// - Throws: An error if the signing operation fails or if the resulting signature cannot be used to create a Signature instance.
    func sign(data: Data) throws -> Signature
}
