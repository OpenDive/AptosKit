//
//  ZkProof.swift
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

/// A container for a different zero knowledge proof types
public struct ZkProof: KeyProtocol, Equatable {
    public var proof: any ZKPProtocol

    /// Index of the underlying enum variant
    public var variant: ZkpVariant

    public init(proof: any ZKPProtocol, variant: ZkpVariant) {
        self.proof = proof
        self.variant = variant
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(self.variant.rawValue))
        try self.proof.serialize(serializer)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ZkProof {
        let index = try deserializer.uleb128()

        switch (index) {
        case 0:
            return try ZkProof(
                proof: Groth16Zkp.deserialize(from: deserializer),
                variant: ZkpVariant.init(rawValue: Int(index))!
            )
        default:
            throw AptosError.invalidVariant
        }
    }

    static public func ==(lhs: ZkProof, rhs: ZkProof) -> Bool {
        let lhsSer = Serializer()
        let rhsSer = Serializer()

        guard ((try? lhs.proof.serialize(lhsSer)) != nil) else {
            return false
        }
        guard ((try? rhs.proof.serialize(Serializer())) != nil) else {
            return false
        }

        return lhs.variant == rhs.variant && lhsSer.output() == rhsSer.output()
    }
}
