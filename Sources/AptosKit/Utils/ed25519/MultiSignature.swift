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
        var bitmap = 0
        
        for entry in signatureMap {
            self.signatures.append(entry.1)
            if let index = publicKey.keys.firstIndex(of: entry.0) {
                let shift = 31 - index
                bitmap = bitmap | (1 << shift)
            }
        }
        
        self.bitmap = withUnsafeBytes(of: bitmap) { Data($0) }
    }
}
