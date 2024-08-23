//
//  Groth16Zkp.swift
//  
//
//  Created by Marcus Arnett on 8/14/24.
//

import Foundation

/// A representation of a Groth16 proof.  
/// The points are the compressed serialization of affine reprentation of the proof.
public struct Groth16Zkp: ZKPProtocol {
    /// The bytes of G1 proof point a
    public var a: G1Bytes

    /// The bytes of G2 proof point b
    public var b: G2Bytes

    /// The bytes of G1 proof point c
    public var c: G1Bytes

    public init(a: Data, b: Data, c: Data) throws {
        self.a = try G1Bytes(data: a)
        self.b = try G2Bytes(data: b)
        self.c = try G1Bytes(data: c)
    }

    public init(a: G1Bytes, b: G2Bytes, c: G1Bytes) throws {
        self.a = a
        self.b = b
        self.c = c
    }

    public func serialize(_ serializer: Serializer) throws {
        try self.a.serialize(serializer)
        try self.b.serialize(serializer)
        try self.c.serialize(serializer)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Groth16Zkp {
        return try Groth16Zkp(
            a: G1Bytes.deserialize(from: deserializer),
            b: G2Bytes.deserialize(from: deserializer),
            c: G1Bytes.deserialize(from: deserializer)
        )
    }
}
