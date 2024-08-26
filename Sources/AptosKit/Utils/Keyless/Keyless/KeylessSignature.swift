//
//  KeylessSignature.swift
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

/// A signature of a message signed via Keyless Accounnt that uses proofs or the jwt token to authenticate.
public struct KeylessSignature: AptosSignatureProtocol {
    /// The inner signature ZeroKnowledgeSigniature or OpenIdSignature
    public var ephemeralCertificate: EphemeralCertificate

    /// The jwt header in the token used to create the proof/signature.  In json string representation.
    public var jwtHeader: String

    /// The expiry timestamp in seconds of the EphemeralKeyPair used to sign
    public var expiryDateSecs: Int

    /// The ephemeral public key used to verify the signature
    public var ephemeralPublicKey: EphemeralPublicKey

    /// The signature resulting from signing with the private key of the EphemeralKeyPair
    public var ephemeralSignature: EphemeralSignature

    public var description: String { "TODO" }

    public init(
        ephemeralCertificate: EphemeralCertificate,
        jwtHeader: String,
        expiryDateSecs: Int,
        ephemeralPublicKey: EphemeralPublicKey,
        ephemeralSignature: EphemeralSignature
    ) {
        self.ephemeralCertificate = ephemeralCertificate
        self.jwtHeader = jwtHeader
        self.expiryDateSecs = expiryDateSecs
        self.ephemeralPublicKey = ephemeralPublicKey
        self.ephemeralSignature = ephemeralSignature
    }

    public func serialize(_ serializer: Serializer) throws {
        try self.ephemeralCertificate.serialize(serializer)
        try Serializer.str(serializer, self.jwtHeader)
        try Serializer.u64(serializer, self.expiryDateSecs)
        try self.ephemeralPublicKey.serialize(serializer)
        try self.ephemeralSignature.serialize(serializer)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> KeylessSignature {
        return try KeylessSignature(
            ephemeralCertificate: EphemeralCertificate.deserialize(from: deserializer),
            jwtHeader: Deserializer.string(deserializer),
            expiryDateSecs: Int(Deserializer.u64(deserializer)),
            ephemeralPublicKey: EphemeralPublicKey.deserialize(from: deserializer),
            ephemeralSignature: EphemeralSignature.deserialize(from: deserializer)
        )
    }
}
