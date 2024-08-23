//
//  ZkProof.swift
//  
//
//  Created by Marcus Arnett on 8/14/24.
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
