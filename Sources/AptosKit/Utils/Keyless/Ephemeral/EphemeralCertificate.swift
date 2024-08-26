//
//  EphemeralCertificate.swift
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

public struct EphemeralCertificate: AptosSignatureProtocol {
    public var signature: Signature

    /// Index of the underlying enum variant
    public var variant: EphemeralSignatureVariant

    public var description: String { self.signature.description }

    public init(signature: Signature, variant: EphemeralSignatureVariant) {
        self.signature = signature
        self.variant = variant
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(self.variant.rawValue))
        try self.signature.serialize(serializer)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> EphemeralCertificate {
        let index = try deserializer.uleb128()

        switch (index) {
        case 0:
            return EphemeralCertificate(
                signature: try Signature.deserialize(from: deserializer),
                variant: .Ed25519
            )
        default:
            throw AptosError.invalidVariant
        }
    }
}
