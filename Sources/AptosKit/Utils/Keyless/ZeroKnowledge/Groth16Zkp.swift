//
//  Groth16Zkp.swift
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
