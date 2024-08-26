//
//  ZeroKnowledgeSignature.swift
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

/// The signature representation of a proof
public struct ZeroKnowledgeSignature: AptosSignatureProtocol {
    /// The proof
    public var proof: ZkProof

    /// The maximum lifespan of the proof
    public var expHorizonSecs: Int

    /// A key value pair on the JWT token that can be specified on the signature which would reveal the value on chain.
    /// Can be used to assert identity or other attributes.
    public var extraField: String?

    /// The 'aud' value of the recovery service which is set when recovering an account.
    public var overrideAudVal: String?

    /// The training wheels signature
    public var trainingWheelsSignature: EphemeralSignature?

    public init(
        proof: ZkProof,
        expHorizonSecs: Int,
        extraField: String? = nil,
        overrideAudVal: String? = nil,
        trainingWheelsSignature: EphemeralSignature? = nil
    ) {
        self.proof = proof
        self.expHorizonSecs = expHorizonSecs
        self.extraField = extraField
        self.overrideAudVal = overrideAudVal
        self.trainingWheelsSignature = trainingWheelsSignature
    }

    public var description: String {
        let ser = Serializer()
        try! self.serialize(ser)
        return "\([UInt8](ser.output()))"
    }

    public func serialize(_ serializer: Serializer) throws {
        try self.proof.serialize(serializer)
        try Serializer.u64(serializer, self.expHorizonSecs)
        try serializer.optional(Serializer.str, self.extraField)
        try serializer.optional(Serializer.str, self.overrideAudVal)
        try serializer.optional(Serializer._struct, self.trainingWheelsSignature)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ZeroKnowledgeSignature {
        return try ZeroKnowledgeSignature(
            proof: ZkProof.deserialize(from: deserializer),
            expHorizonSecs: Int(Deserializer.u64(deserializer)),
            extraField: deserializer.optional(valueDecoder: Deserializer.string),
            overrideAudVal: deserializer.optional(valueDecoder: Deserializer.string),
            trainingWheelsSignature: deserializer.optional(valueDecoder: Deserializer._struct)
        )
    }
}
