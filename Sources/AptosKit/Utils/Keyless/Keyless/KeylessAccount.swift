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

//    public func signWithAuthenticator(message: Data) throws ->

//
//      /**
//       * Sign a message using Keyless.
//       * @param message the message to sign, as binary input
//       * @return the AccountAuthenticator containing the signature, together with the account's public key
//       */
//      signWithAuthenticator(message: HexInput): AccountAuthenticatorSingleKey {
//        const signature = new AnySignature(this.sign(message));
//        const publicKey = new AnyPublicKey(this.publicKey);
//        return new AccountAuthenticatorSingleKey(publicKey, signature);
//      }
//
//      /**
//       * Sign a transaction using Keyless.
//       * @param transaction the raw transaction
//       * @return the AccountAuthenticator containing the signature of the transaction, together with the account's public key
//       */
//      signTransactionWithAuthenticator(transaction: AnyRawTransaction): AccountAuthenticatorSingleKey {
//        const signature = new AnySignature(this.signTransaction(transaction));
//        const publicKey = new AnyPublicKey(this.publicKey);
//        return new AccountAuthenticatorSingleKey(publicKey, signature);
//      }
//
//      /**
//       * Waits for asyncronous proof fetching to finish.
//       * @return
//       */
//      async waitForProofFetch() {
//        if (this.proofOrPromise instanceof Promise) {
//          await this.proofOrPromise;
//        }
//      }
//
//      /**
//       * Sign the given message using Keyless.
//       * @param message in HexInput format
//       * @returns Signature
//       */
//      sign(data: HexInput): KeylessSignature {
//        const { expiryDateSecs } = this.ephemeralKeyPair;
//        if (this.isExpired()) {
//          throw new Error("EphemeralKeyPair is expired");
//        }
//        if (this.proof === undefined) {
//          throw new Error("Proof not defined");
//        }
//        const ephemeralPublicKey = this.ephemeralKeyPair.getPublicKey();
//        const ephemeralSignature = this.ephemeralKeyPair.sign(data);
//
//        return new KeylessSignature({
//          jwtHeader: base64UrlDecode(this.jwt.split(".")[0]),
//          ephemeralCertificate: new EphemeralCertificate(this.proof, EphemeralCertificateVariant.ZkProof),
//          expiryDateSecs,
//          ephemeralPublicKey,
//          ephemeralSignature,
//        });
//      }
//
//      /**
//       * Sign the given transaction with Keyless.
//       * Signs the transaction and proof to guard against proof malleability.
//       * @param transaction the transaction to be signed
//       * @returns KeylessSignature
//       */
//      signTransaction(transaction: AnyRawTransaction): KeylessSignature {
//        if (this.proof === undefined) {
//          throw new Error("Proof not found");
//        }
//        const raw = deriveTransactionType(transaction);
//        const txnAndProof = new TransactionAndProof(raw, this.proof.proof);
//        const signMess = txnAndProof.hash();
//        return this.sign(signMess);
//      }
//
//      /**
//       * Note - This function is currently incomplete and should only be used to verify ownership of the KeylessAccount
//       *
//       * Verifies a signature given the message.
//       *
//       * TODO: Groth16 proof verification
//       *
//       * @param args.message the message that was signed.
//       * @param args.signature the KeylessSignature to verify
//       * @returns boolean
//       */
//      verifySignature(args: { message: HexInput; signature: KeylessSignature }): boolean {
//        const { message, signature } = args;
//        if (this.isExpired()) {
//          return false;
//        }
//        if (!this.ephemeralKeyPair.getPublicKey().verifySignature({ message, signature: signature.ephemeralSignature })) {
//          return false;
//        }
//        return true;
//      }

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
