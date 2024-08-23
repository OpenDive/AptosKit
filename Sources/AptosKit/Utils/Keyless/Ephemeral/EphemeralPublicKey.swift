//
//  EphemeralPublicKey.swift
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
import ed25519swift

public struct EphemeralPublicKey: PublicKeyProtocol {
    public var key: Data

    public var variant: EphemeralPublicKeyVariant

    public var description: String { "\([UInt8](self.key))" }

    public var hex: String { "0x\(self.key.hexEncodedString())" }

    public init(data: Data, variant: EphemeralPublicKeyVariant = .Ed25519) throws {
        switch variant {
        case .Ed25519:
            guard data.count <= ED25519PublicKey.LENGTH else {
                throw AptosError.invalidPublicKey
            }
            self.key = data
            self.variant = variant
        }
    }

    public func verifySignature(withMessage message: Data, andSignature signature: EphemeralSignature) -> Bool {
        return Ed25519.verify(
            signature: signature.signature.bytes,
            message: message.bytes,
            publicKey: self.key.bytes
        )
    }

    public func serialize(_ serializer: Serializer) throws {
        switch self.variant {
        case .Ed25519:
            try serializer.uleb128(UInt(self.variant.rawValue))
            try Serializer.toBytes(serializer, self.key)
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> EphemeralPublicKey {
        let index = try deserializer.uleb128()

        switch index {
        case 0:
            return try EphemeralPublicKey(data: try Deserializer.toBytes(deserializer), variant: .Ed25519)
        default:
            throw AptosError.invalidPublicKey
        }
    }
}
