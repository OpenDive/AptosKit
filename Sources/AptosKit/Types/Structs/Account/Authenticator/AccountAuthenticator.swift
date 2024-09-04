//
//  AccountAuthenticator.swift
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

/// The structure used to represent an account authenticator.
public struct AccountAuthenticator: Equatable, KeyProtocol {
    public static let ed25519: Int = 0
    public static let multiEd25519: Int = 1
    public static let keyless: Int = 2

    let variant: Int
    let authenticator: any AccountAuthenticatorProtocol

    public init(authenticator: any AccountAuthenticatorProtocol) throws {
        if authenticator is Ed25519AcocuntAuthenticator {
            variant = AccountAuthenticator.ed25519
        } else if authenticator is MultiEd25519AcocuntAuthenticator {
            variant = AccountAuthenticator.multiEd25519
        } else if authenticator is KeylessAccountAuthenticator {
            variant = AccountAuthenticator.keyless
        } else {
            throw AptosError.invalidAuthenticatorType
        }
        self.authenticator = authenticator
    }

    public static func fromKey(key: any PublicKeyProtocol) throws -> Int {
        if key is ED25519PublicKey {
            return AccountAuthenticator.ed25519
        } else if key is MultiED25519PublicKey {
            return AccountAuthenticator.multiEd25519
        } else if key is KeylessPublicKey {
            return AccountAuthenticator.keyless
        } else {
            throw AptosError.invalidAuthenticatorType
        }
    }

    public static func == (lhs: AccountAuthenticator, rhs: AccountAuthenticator) -> Bool {
        return try!
            lhs.variant == rhs.variant &&
            lhs.authenticator.bcsBytes() == rhs.authenticator.bcsBytes()
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(variant))
        try Serializer._struct(serializer, value: self.authenticator)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> AccountAuthenticator {
        let variant = try deserializer.uleb128()

        var authenticator: any AccountAuthenticatorProtocol

        if variant == AccountAuthenticator.ed25519 {
            authenticator = try Ed25519AcocuntAuthenticator.deserialize(from: deserializer)
        } else if variant == AccountAuthenticator.multiEd25519 {
            authenticator = try MultiEd25519AcocuntAuthenticator.deserialize(from: deserializer)
        } else if variant == AccountAuthenticator.keyless {
            authenticator = try KeylessAccountAuthenticator.deserialize(from: deserializer)
        } else {
            throw AptosError.invalidType(type: String(variant))
        }

        return try AccountAuthenticator(authenticator: authenticator)
    }
}
