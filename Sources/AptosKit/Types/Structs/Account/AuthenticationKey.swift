//
//  AuthenticationKey.swift
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
import CryptoSwift

public struct AuthenticationKey: KeyProtocol, CustomStringConvertible {
    public static let LENGTH = 32

    public var data: Data

    public var description: String { "\(self.data.bytes)" }

    public init(data: Data) throws {
        guard data.count == AuthenticationKey.LENGTH else {
            throw AptosError.invalidLength
        }
        self.data = data
    }

    public static func fromSchemeAndBytes(_ scheme: any AuthenticationKeyScheme, _ input: Data) throws -> AuthenticationKey {
        var hashInput = Data()
        hashInput.append(contentsOf: input.bytes)
        hashInput.append(UInt8(scheme.rawValue))
        let hashed = hashInput.sha3(.sha256)
        return try AuthenticationKey(data: hashed)
    }

    /// Converts a PublicKey(s) to an AuthenticationKey, using the derivation scheme inferred from the
    /// instance of the PublicKey type passed in.
    /// - Parameter publicKey: The public key that contains the authentication key.
    /// - Returns: `AuthenticationKey`
    public static func fromPublicKey(_ publicKey: any AccountPublicKey) throws -> AuthenticationKey {
        return try publicKey.authKey()
    }

    /// Derives an account address from an AuthenticationKey. Since an AccountAddress is also 32 bytes,
    /// the AuthenticationKey bytes are directly translated to an AccountAddress.
    /// - Returns: `AccountAddress`
    public func derivedAddress() throws -> AccountAddress {
        return try AccountAddress(address: self.data)
    }

    public func serialize(_ serializer: Serializer) throws {
        serializer.fixedBytes(self.data)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> AuthenticationKey {
        return try AuthenticationKey(data: deserializer.fixedBytes(length: AuthenticationKey.LENGTH))
    }
}
