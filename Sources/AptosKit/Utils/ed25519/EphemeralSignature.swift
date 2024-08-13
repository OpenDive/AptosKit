//
//  EphemeralSignature.swift
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

/// Represents ephemeral signatures used in Aptos Keyless accounts.
/// These signatures are used inside of KeylessSignature
public struct EphemeralSignature: AptosSignatureProtocol {
    /// The signature itself
    public var signature: Data

    public var variant: EphemeralSignatureVariant

    public var description: String  { "\([UInt8](self.signature))" }

    public var hex: String { "0x\(self.signature.hexEncodedString())" }

    public init(signature: Data, variant: EphemeralSignatureVariant = .Ed25519) {
        switch variant {
        case .Ed25519:
            self.signature = signature
            self.variant = variant
        }
    }

    public init(hexSignature: String) throws {
        let der = Deserializer(data: Data(hex: hexSignature))
        let result = try EphemeralSignature.deserialize(from: der)
        self.init(signature: result.signature, variant: result.variant)
    }

    public init (rawSignature: Signature, variant: EphemeralSignatureVariant = .Ed25519) {
        self.signature = rawSignature.signature
        self.variant = variant
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(self.variant.rawValue))
        try Serializer.toBytes(serializer, self.signature)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> EphemeralSignature {
        let index = try deserializer.uleb128()

        switch index {
        case 0:
            return EphemeralSignature(rawSignature: try Signature.deserialize(from: deserializer), variant: .Ed25519)
        default:
            throw AptosError.invalidSerializedSignature
        }
    }
}
