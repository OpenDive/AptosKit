//
//  KeylessAccount.swift
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
import JWTDecode

/// Account implementation for the Keyless authentication scheme.
///
/// Used to represent a Keyless based account and sign transactions with it.
///
/// Use KeylessAccount.fromJWTAndProof to instantiate a KeylessAccount with a JWT, proof and EphemeralKeyPair.
///
/// When the proof expires or the JWT becomes invalid, the KeylessAccount must be instantiated again with a new JWT,
/// EphemeralKeyPair, and corresponding proof.
public struct KeylessAccount: KeyProtocol {
    public static let PEPPER_LENGTH = 31

    /// The KeylessPublicKey associated with the account
    public var publicKey: KeylessPublicKey

    /// The EphemeralKeyPair used to generate sign
    public var ephemeralKeyPair: EphemeralKeyPair

    /// The claim on the JWT to identify a user.  This is typically 'sub' or 'email'.
    public var uidKey: String

    /// The value of the uidKey claim on the JWT.  This intended to be a stable user identifier.
    public var uidVal: String

    /// The value of the 'aud' claim on the JWT, also known as client ID.  This is the identifier for the dApp's
    /// OIDC registration with the identity provider.
    public var aud: String

    /// A value contains 31 bytes of entropy that preserves privacy of the account. Typically fetched from a pepper provider.
    public var pepper: Data

    /// Account address associated with the account
    public var accountAddress: AccountAddress

    /// The zero knowledge signature (if ready) which contains the proof used to validate the EphemeralKeyPair.
    public var proof: ZeroKnowledgeSignature?

    /// Signing scheme used to sign transactions
    public var signingScheme: SigningScheme

    /// The JWT token used to derive the account
    public var jwt: String

    // Use the static constructor 'create' instead.
    private init(
        address: AccountAddress? = nil,
        ephemeralKeyPair: EphemeralKeyPair,
        iss: String,
        uidKey: String,
        uidVal: String,
        aud: String,
        pepper: Data,
        proof: ZeroKnowledgeSignature? = nil,
        jwt: String
    ) throws {
        let pubKey = try KeylessPublicKey.create(iss, uidKey, uidVal, aud, pepper)
        self.ephemeralKeyPair = ephemeralKeyPair
        self.publicKey = pubKey
        self.accountAddress = try address ?? pubKey.authKey().derivedAddress()
        self.uidKey = uidKey
        self.uidVal = uidVal
        self.aud = aud
        self.pepper = pepper
        self.jwt = jwt
        self.proof = proof
        self.signingScheme = .SingleKey

        guard pepper.count == Self.PEPPER_LENGTH else {
            throw AptosError.invalidLength
        }

        self.pepper = pepper
    }

    public static func create(
        address: AccountAddress? = nil,
        proof: ZeroKnowledgeSignature? = nil,
        jwt: String,
        ephemeralKeyPair: EphemeralKeyPair,
        pepper: Data,
        uidKeyRaw: String? = nil
    ) throws -> KeylessAccount {
        let uidKey = uidKeyRaw ?? "sub"
        let jwtPayload = try decode(jwt: jwt)

        guard
            let uidVal = jwtPayload.body[uidKey] as? String,
            let iss = jwtPayload.body["iss"] as? String,
            let aud = jwtPayload.body["aud"] as? String
        else { throw AptosError.notImplemented }

        return try KeylessAccount(
            address: address,
            ephemeralKeyPair: ephemeralKeyPair,
            iss: iss,
            uidKey: uidKey,
            uidVal: uidVal,
            aud: aud,
            pepper: pepper,
            proof: proof,
            jwt: jwt
        )
    }

    /// Checks if the proof is expired.  If so the account must be rederived with a new EphemeralKeyPair
    /// and JWT token.
    /// - Returns: Bool
    public func isExpired() -> Bool {
        return self.ephemeralKeyPair.isExpired()
    }

    /// Sign a message using Keyless.
    /// - Parameter message: The message to sign, as binary input.
    /// - Returns: The AccountAuthenticator containing the signature, together with the account's public key.
    public func signWithAuthenticator(message: Data) throws -> KeylessAccountAuthenticator {
        let signature = try self.sign(data: message)
        let publicKey = self.publicKey

        return KeylessAccountAuthenticator(publicKey: publicKey, signature: signature)
    }

    /// Sign a message using Keyless.
    /// - Parameter transaction: The raw transaction.
    /// - Returns: The AccountAuthenticator containing the signature of the transaction, together with the account's public key.
    public func signWithTransactionAuthenticator(
        transaction: RawTransaction
    ) throws -> KeylessAccountAuthenticator {
        let signature = try self.signTransaction(transaction: transaction)
        let publicKey = self.publicKey

        return KeylessAccountAuthenticator(publicKey: publicKey, signature: signature)
    }

    /// Sign the given message using Keyless.
    /// - Parameter data: Message in Data format.
    /// - Returns: KeylessSignature
    public func sign(data: Data) throws -> KeylessSignature {
        let expiraryDateSeconds = self.ephemeralKeyPair.expiryDateSecs
        guard self.isExpired() == false else {
            throw AptosError.expiredEpheremalKeyPair
        }
        guard let proof = self.proof else {
            throw AptosError.undefinedProof
        }
        let ephemeralPublicKey = self.ephemeralKeyPair.publicKey
        let ephemeralSignature = try self.ephemeralKeyPair.sign(data: data)

        return KeylessSignature(
            ephemeralCertificate: EphemeralCertificate(signature: proof, variant: .ZkProof),
            jwtHeader: String(self.jwt.split(separator: ".")[0]),
            expiryDateSecs: expiraryDateSeconds,
            ephemeralPublicKey: ephemeralPublicKey,
            ephemeralSignature: ephemeralSignature
        )
    }

    public func signTransaction(transaction: RawTransaction) throws -> KeylessSignature {
        guard let proof = self.proof else {
            throw AptosError.undefinedProof
        }
        let txAndProof = TransactionAndProof(transaction: transaction, proof: proof.proof)
        let signedMessage = try txAndProof.sign(key: self.ephemeralKeyPair.privateKey)
        return try self.sign(data: signedMessage.signature)
    }

    // TODO: Groth16 proof verification
    /// Verifies a signature given the message.
    ///
    /// - Note: This function is currently incomplete and should only be used to verify ownership of the KeylessAccount
    /// - Parameters:
    ///   - message: The message that was signed.
    ///   - signature: The KeylessSignature to verify.
    /// - Returns: Bool
    public func verifySignature(message: Data, signature: KeylessSignature) throws -> Bool {
        guard self.isExpired() == false else {
            return false
        }
        return self.ephemeralKeyPair.publicKey.verifySignature(
            withMessage: message,
            andSignature: signature.ephemeralSignature
        )
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, self.jwt)
        try Serializer.str(serializer, self.uidKey)
        serializer.fixedBytes(self.pepper)
        try self.ephemeralKeyPair.serialize(serializer)

        guard let proof = self.proof else {
            throw AptosError.undefinedProof
        }

        try proof.serialize(serializer)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> KeylessAccount {
        let jwt = try Deserializer.string(deserializer)
        let uidKey = try Deserializer.string(deserializer)
        let pepper = try deserializer.fixedBytes(length: Self.PEPPER_LENGTH)
        let ephemeralKeyPair = try EphemeralKeyPair.deserialize(from: deserializer)
        let proof = try ZeroKnowledgeSignature.deserialize(from: deserializer)

        return try KeylessAccount.create(
            proof: proof,
            jwt: jwt,
            ephemeralKeyPair: ephemeralKeyPair,
            pepper: pepper,
            uidKeyRaw: uidKey
        )
    }
}
