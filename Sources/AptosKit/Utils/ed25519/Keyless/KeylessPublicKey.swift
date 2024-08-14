//
//  KeylessPublicKey.swift
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

/// Represents the KeylessPublicKey public key
/// KeylessPublicKey authentication key is represented in the SDK as `PublicKeyProtocol`.
public struct KeylessPublicKey: AccountPublicKey {
    /// The number of bytes that `idCommitment` should be
    public static let ID_COMMITMENT_LENGTH = 32

    public var key: Data

    /// The value of the 'iss' claim on the JWT which identifies the OIDC provider.
    public var iss: String

    /// A value representing a cryptographic commitment to a user identity.
    /// It is calculated from the aud, uidKey, uidVal, pepper.
    public var idCommitment: Data

    public var description: String {
        "Keyless Public Key - iss: \(self.iss), idCommitment: \(self.idCommitment.bytes)"
    }

    public init(iss: String, idCommitment: Data) throws {
        self.key = Data()
        guard idCommitment.count == KeylessPublicKey.ID_COMMITMENT_LENGTH else {
            throw AptosError.invalidLength
        }
        self.iss = iss
        self.idCommitment = idCommitment
    }

    /// Creates a KeylessPublicKey from the JWT components plus pepper
    /// - Parameters:
    ///   - iss: the iss of the identity
    ///   - uidKey: the key to use to get the uidVal in the JWT token
    ///   - uidVal: the value of the uidKey in the JWT token
    ///   - aud: the client ID of the application
    ///   - pepper: The pepper used to maintain privacy of the account
    /// - Returns: `KeylessPublicKey`
    public static func create(
        _ iss: String,
        _ uidKey: String,
        _ uidVal: String,
        _ aud: String,
        _ pepper: Data
    ) throws -> KeylessPublicKey {
        let computedIdCommitment = try KeylessUtilities.computeIdCommitment(uidKey, uidVal, aud, pepper)
        return try KeylessPublicKey(iss: iss, idCommitment: computedIdCommitment)
    }

    public static func fromJwtAndPepper(
        _ jwt: String,
        _ pepper: Data,
        _ uidKeyRaw: String? = nil
    ) throws -> KeylessPublicKey {
        let uidKey = uidKeyRaw ?? "sub"
        let decodedJwt = try decode(jwt: jwt)

        guard
            let uidVal = decodedJwt.body[uidKey] as? String,
            let iss = decodedJwt.body["iss"] as? String,
            let aud = decodedJwt.body["aud"] as? String
        else { throw AptosError.notImplemented }

        return try KeylessPublicKey.create(iss, uidKey, uidVal, aud, pepper)
    }

    /// Get the authentication key for the keyless public key
    /// - Returns: `AuthenticationKey`
    public func authKey() throws -> AuthenticationKey {
        let ser = Serializer()
        try ser.uleb128(UInt(AnyPublicKeyVariant.Keyless.rawValue))
        try self.serialize(ser)
        return try AuthenticationKey.fromSchemeAndBytes(
            SigningScheme.SingleKey,
            ser.output()
        )
    }

    public func verify(data: Data, signature: MultiSignature) throws -> Bool {
        throw AptosError.notImplemented
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.str(serializer, self.iss)
        try Serializer.toBytes(serializer, self.idCommitment)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> KeylessPublicKey {
        return try KeylessPublicKey(
            iss: Deserializer.string(deserializer),
            idCommitment: Deserializer.toBytes(deserializer)
        )
    }
}
