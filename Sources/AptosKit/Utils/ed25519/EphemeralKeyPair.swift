//
//  EphemeralKeyPair.swift
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
import BigInt

/// A class which contains a key pair that is used in signing transactions via the Keyless authentication scheme. This key pair
/// is ephemeral and has an expiration time.  For more details on
/// [how this class is used](https://aptos.dev/guides/keyless-accounts/#1-present-the-user-with-a-sign-in-with-idp-button-on-the-ui).
public struct EphemeralKeyPair: KeyProtocol {
    public static let TWO_WEEKS_IN_SECONDS = 1_209_600
    public static let BLINDER_LENGTH = 31

    /// A byte array of length BLINDER_LENGTH used to obfuscate the public key from the IdP.
    /// Used in calculating the nonce passed to the IdP and as a secret witness in proof generation.
    public var blinder: Data

    /// A timestamp in seconds indicating when the ephemeral key pair is expired.  After expiry, a new
    /// EphemeralKeyPair must be generated and a new JWT needs to be created.
    public var expiryDateSecs: Int

    /// The value passed to the IdP when the user authenticates.  It comprises of a hash of the
    /// ephermeral public key, expiry date, and blinder.
    public var nonce: String

    /// A private key used to sign transactions.  This private key is not tied to any account on the chain as
    /// is ephemeral (not permanent) in nature.
    public var privateKey: any PrivateKeyProtocol

    /// A public key used to verify transactions.  This public key is not tied to any account on the chain as
    /// is ephemeral (not permanent) in nature.
    public var publicKey: EphemeralPublicKey

    public init(privateKey: any PrivateKeyProtocol, expiryDateSecs: Int? = nil, blinder: Data? = nil) throws {
        self.privateKey = privateKey
        self.publicKey = try EphemeralPublicKey(data: privateKey.publicKey().key as! Data)

        // By default, we set the expiry date to be two weeks in the future floored to the nearest hour
        self.expiryDateSecs = expiryDateSecs ?? Int(
            AptosUtilities.floorToWholeHour(
                timestampInSeconds: AptosUtilities.nowInSeconds() + Double(EphemeralKeyPair.TWO_WEEKS_IN_SECONDS)
            )
        )

        // Generate the blinder if not provided
        self.blinder = blinder ?? EphemeralKeyPair.generateBlinder()

        // Calculate the nonce
        let ser = Serializer()
        try publicKey.serialize(ser)
        var fields = try PoseidonUtilities.padAndPackBytesWithLen(bytes: ser.output().bytes, maxSizeBytes: 93)
        fields.append(BigInt(self.expiryDateSecs))
        fields.append(PoseidonUtilities.bytesToBigIntLE(bytes: self.blinder.bytes))
        self.nonce = "\(try PoseidonUtilities.poseidonHash(inputs: fields))"
    }

    public init(scheme: EphemeralPublicKeyVariant = .Ed25519, expiryDateSecs: Int? = nil) throws {
        let privateKey: any PrivateKeyProtocol

        switch (scheme) {
        case .Ed25519:
            privateKey = try ED25519PrivateKey.random()
        }

        try self.init(privateKey: privateKey, expiryDateSecs: expiryDateSecs)
    }

    public static func fromBytes(with bytes: Data) throws -> EphemeralKeyPair {
        let der = Deserializer(data: bytes)
        return try EphemeralKeyPair.deserialize(from: der)
    }
    
    /// Returns the public key of the key pair.
    /// - Returns: Bool
    public func isExpired() -> Bool {
        return AptosUtilities.nowInSeconds() > Double(self.expiryDateSecs)
    }

    /// Sign the given message with the private key.
    /// - Parameter data: In Data format
    /// - Returns: EphemeralSignature
    public func sign(data: Data) throws -> EphemeralSignature {
        guard !(self.isExpired()) else {
            throw AptosError.expiredEpheremalKeyPair
        }
        return try EphemeralSignature(rawSignature: self.privateKey.sign(data: data))
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(self.publicKey.variant.rawValue))
        try Serializer.toBytes(serializer, self.privateKey.key as! Data)
        try Serializer.u64(serializer, self.expiryDateSecs)
        serializer.fixedBytes(self.blinder)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> EphemeralKeyPair {
        let variant = try deserializer.uleb128()

        switch (variant) {
        case 0:
            let privateKey = try ED25519PrivateKey.deserialize(from: deserializer)
            let expiryDateSecs = try Deserializer.u64(deserializer)
            let blinder = try deserializer.fixedBytes(length: 31)
            return try EphemeralKeyPair(
                privateKey: privateKey,
                expiryDateSecs: Int(expiryDateSecs),
                blinder: blinder
            )
        default:
            throw AptosError.invalidEphemeralPublicKeyVariant(variant: Int(variant))
        }
    }

    /// Generates a random byte array of length EphemeralKeyPair.BLINDER_LENGTH
    /// - Returns: Data
    private static func generateBlinder() -> Data {
        return Data((0..<EphemeralKeyPair.BLINDER_LENGTH).map { _ in UInt8.random(in: 0...255) })
    }
}
