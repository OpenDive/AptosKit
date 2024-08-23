//
//  EphemeralCertificate.swift
//  
//
//  Created by Marcus Arnett on 8/14/24.
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
//        case 0:
//            return EphemeralCertificate(signature: ..., variant: index)
        default:
            throw AptosError.invalidVariant
        }
    }
}
