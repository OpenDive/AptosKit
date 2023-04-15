//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/13/23.
//

import Foundation

public struct MultiSignature {
    public var signatures: [Signature]
    public var bitmap: Data
    
    init(publicKey: MultiPublicKey, signatureMap: [(PublicKey, Signature)]) {
        self.signatures = []
        var bitmap: UInt32 = 0
        
        for entry in signatureMap {
            self.signatures.append(entry.1)
            if let index = publicKey.keys.firstIndex(of: entry.0) {
                let shift = 31 - index
                bitmap = bitmap | (1 << shift)
            }
        }
        
        self.bitmap = withUnsafeBytes(of: (bitmap.bigEndian, UInt32.self)) { Data($0) }.prefix(4)
    }
    
    public func toBytes() -> Data {
        var concatenatedSignatures: Data = Data()
        for signature in self.signatures {
            concatenatedSignatures += signature.data()
        }
        return concatenatedSignatures + self.bitmap
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.toBytes())
    }
}
