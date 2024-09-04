//
//  MultiEd25519AcocuntAuthenticator.swift
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

public struct MultiEd25519AcocuntAuthenticator: AccountAuthenticatorProtocol {
    public typealias PublicKeyType = MultiED25519PublicKey

    public typealias SignatureType = MultiSignature

    public var publicKey: PublicKeyType

    public var signature: SignatureType

    public init(publicKey: MultiED25519PublicKey, signature: MultiSignature) {
        self.publicKey = publicKey
        self.signature = signature
    }

    public func serialize(_ serializer: Serializer) throws {
        try self.publicKey.serialize(serializer)
        try self.signature.serialize(serializer)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> MultiEd25519AcocuntAuthenticator {
        return try MultiEd25519AcocuntAuthenticator(
            publicKey: MultiED25519PublicKey.deserialize(from: deserializer),
            signature: MultiSignature.deserialize(from: deserializer)
        )
    }
}
