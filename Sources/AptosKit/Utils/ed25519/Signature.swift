//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import Foundation

public struct Signature: Equatable, KeyProtocol, CustomStringConvertible {
    static let LENGTH: Int = 64

    var signature: Data

    init(signature: Data) {
        self.signature = signature
    }

    public static func == (lhs: Signature, rhs: Signature) -> Bool {
        return lhs.signature == rhs.signature
    }
    
    public var description: String {
        return "0x\(signature.hexEncodedString())"
    }

    func data() -> Data {
        return self.signature
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Signature {
        let signatureBytes = try Deserializer.toBytes(deserializer)
        if signatureBytes.count != LENGTH {
            throw NSError(domain: "Invalid Length", code: -1)
        }
        return Signature(signature: signatureBytes)
    }

    public func serialize(_ serializer: Serializer) {
        Serializer.toBytes(serializer, self.signature)
    }
}
