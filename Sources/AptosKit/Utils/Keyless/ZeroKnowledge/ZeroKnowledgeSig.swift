//
//  ZeroKnowledgeSig.swift
//  
//
//  Created by Marcus Arnett on 8/14/24.
//

/// The signature representation of a proof
public struct ZeroKnowledgeSignature: AptosSignatureProtocol {
    /// The proof
    public var proof: ZkProof

    /// The maximum lifespan of the proof
    public var expHorizonSecs: Int

    public var description: String { "TODO" }

    public func serialize(_ serializer: Serializer) throws {
        throw AptosError.notImplemented
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ZeroKnowledgeSignature {
        throw AptosError.notImplemented
    }
}
